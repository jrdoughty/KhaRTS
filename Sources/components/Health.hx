package components;

import sdg.event.EventObject;
import sdg.components.Component;
import sdg.Object;
import actors.Actor;
import events.RevealEvent;
import events.HideEvent;
import events.KillEvent;
import events.HurtEvent;
import events.GetSpriteEvent;
/**
 * ...
 * @author ...
 */
class Health extends Component
{
	/**
	 * Int used to decide health using health as a percent of healthMax total
	 */
	public var healthMax:Int = 8;
	/**
	 * simple health bar sprite
	 */
	private var healthBar:Object;
	
	/**
	 * simple health bar fill sprite
	 */
	private var healthBarFill:Object;
	
	private var health:Float = 1;
	
	private var actor:Actor;
	
	public function new() 
	{
		super();
	}
	
	override public function init() 
	{
		super.init();
		
		if (Type.getClass(object) == Actor)
		{
			actor = cast object;
		}
		else
		{
			destroy();
			object.components.remove(this);
		}
		//object.eventDispatcher.addEvent(RevealEvent.REVEAL, makeVisible);
		//object.eventDispatcher.addEvent(HideEvent.HIDE, killVisibility);
		object.eventDispatcher.addEvent(HurtEvent.HURT, hurt);
		//createSprite();
	}
	
	public function hurt(e:HurtEvent)
	{
		health -= e.damage / healthMax;
	}
	
	/**
	 * sets itself and the health bars to no longer be visible
	 */
	public function killVisibility(e:HideEvent = null)
	{
		healthBar.visible = false;
		healthBarFill.visible = false;
	}

	
	/**
	 * Sets itself and the health bars to be visible
	 */
	public function makeVisible(e:RevealEvent = null)
	{
		healthBar.visible = true;
		healthBarFill.visible = true;
	}
	
	/**
	 * keeps up the position of the health bar, and maintains the fill
	 */
	public override function update()
	{
		super.update();
		/*
		if (healthBarFill != null)
		{
			if (health > 0)
			{
				//healthBarFill.graphic.setScale(health, 1);
			}
			else
			{
				healthBarFill.visible = false;
			}
			healthBarFill.x = actor.x;
			healthBarFill.y = actor.y - 1;
			
		}
		if (healthBar != null)
		{
			healthBar.x = actor.x;
			healthBar.y = actor.y - 1;
		}*/
		if (health <= 0)
		{
			kill();
		}
	}
	
	public function createSprite()
	{			
		healthBar = new Object();//actorSprite.x, actorSprite.y - 1,"BLACK",Std.int(Math.sqrt(entity.currentNodes.length) * 8), 1);
		healthBarFill = new Object();//actorSprite.x, actorSprite.y - 1, "RED", Std.int(Math.sqrt(entity.currentNodes.length) * 8), 1);
		object.screen.add(healthBar);
		object.screen.add(healthBarFill);
	}
	
	public function kill(e:EventObject = null)
	{
		/*
		object.screen.remove(healthBar);
		object.screen.remove(healthBarFill);
		*/
		actor.kill();
		object.eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
		object.screen.remove(object, true);
	}
}