package components;

import sdg.event.EventObject;
import sdg.components.Component;
import sdg.Object;
import actors.Actor;
import sdg.event.EventObject;
import events.SimpleEvents;
import events.KillEvent;
import events.HurtEvent;
import sdg.graphics.shapes.Polygon;
import kha.Color;
import components.UIHealth;
/**
 * ...
 * @author ...
 */
class Health extends ActorComponent
{
	
	/**
	* simple health bar sprite
	*/
	public var healthBar:Object;

	/**
	* simple health bar fill sprite
	*/
	public var healthBarFill:Object;
	private var p:Polygon;
	public function new() 
	{
		super();
	}
	
	override public function init() 
	{
		super.init();
		
		object.eventDispatcher.addEvent(SimpleEvents.REVEAL, makeVisible);
		object.eventDispatcher.addEvent(SimpleEvents.HIDE, killVisibility);
		object.eventDispatcher.addEvent(HurtEvent.HURT, hurt);
		createSprite();

	}
	
	public function hurt(e:HurtEvent)
	{
		actor.health -= e.damage / actor.healthMax;
	}
	
	/**
	 * sets itself and the health bars to no longer be visible
	 */
	public function killVisibility(e:EventObject = null)
	{
		healthBar.visible = false;
		healthBarFill.visible = false;
	}

	
	/**
	 * Sets itself and the health bars to be visible
	 */
	public function makeVisible(e:EventObject = null)
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
			if (actor.health > 0)
			{
				p.points[1].x = actor.width*(actor.health);
				p.points[2].x = actor.width*(actor.health);
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
		if (actor.health <= 0)
		{
			kill();
		}
	}
	
	public function createSprite()
	{			
		healthBar = new Object(object.x, object.y, Polygon.createRectangle(actor.width, 1, Color.Red, true));
		p = Polygon.createRectangle(actor.width, 1, Color.Green, true);
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
