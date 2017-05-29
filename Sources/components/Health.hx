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
import sdg.graphics.shapes.Polygon;
import kha.Color;
/**
 * ...
 * @author ...
 */
class Health extends ActorComponent
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
	
	private var p:Polygon;//shortcut
	
	public function new(max:Int = 8) 
	{
		super();
		healthMax = max;
	}
	
	override public function init() 
	{
		super.init();
		
		object.eventDispatcher.addEvent(RevealEvent.REVEAL, makeVisible);
		object.eventDispatcher.addEvent(HideEvent.HIDE, killVisibility);
		object.eventDispatcher.addEvent(HurtEvent.HURT, hurt);
		createSprite();
		if(!actor.data.exists('health'))
		{
			actor.data.set('health', 1);
			trace('health not set');
		}
	}
	
	public function hurt(e:HurtEvent)
	{
		
			actor.data['health'] -= e.damage / healthMax;
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
		
		if (healthBarFill != null)
		{
			if (actor.data['health'] > 0)
			{
				p.points[1].x = actor.width*(actor.data['health']);
				p.points[2].x = actor.width*(actor.data['health']);
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
		}
		if (actor.data['health'] <= 0)
		{
			kill();
		}
	}
	
	public function createSprite()
	{			
		healthBar = new Object(object.x, object.y, Polygon.createRectangle(actor.width, 1, Color.Red, true));
		p = Polygon.createRectangle(actor.width, 1, Color.Green,true);
		healthBarFill = new Object(object.x, object.y, p);
		sdg.Sdg.screen.add(healthBar);
		sdg.Sdg.screen.add(healthBarFill);
	}
	
	public function kill(e:EventObject = null)
	{
		
		object.screen.remove(healthBar);
		object.screen.remove(healthBarFill);
		
		actor.kill();
		object.eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
		object.screen.remove(object, true);
	}
}
