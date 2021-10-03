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
	var data:HealthData = {
		healthBar: null,
		healthBarFill: null,
		actor: null,
		p:null
	}
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
		data.actor = this.actor;
		createSprite();

		Util.getOrInit(data.actor.data, 'healthMax', function(){return cast 1;});
		Util.getOrInit(data.actor.data, 'health', function(){return cast 1;});

	}
	
	public function hurt(e:HurtEvent)
	{
		
		data.actor.data['health'] -= e.damage / actor.data['healthMax'];
	}
	
	/**
	 * sets itself and the health bars to no longer be visible
	 */
	public function killVisibility(e:EventObject = null)
	{
		data.healthBar.visible = false;
		data.healthBarFill.visible = false;
	}

	
	/**
	 * Sets itself and the health bars to be visible
	 */
	public function makeVisible(e:EventObject = null)
	{
		data.healthBar.visible = true;
		data.healthBarFill.visible = true;
	}
	
	/**
	 * keeps up the position of the health bar, and maintains the fill
	 */
	public override function update()
	{
		super.update();
		
		if (data.healthBarFill != null)
		{
			if (actor.data['health'] > 0)
			{
				data.p.points[1].x = data.actor.width*(data.actor.data['health']);
				data.p.points[2].x = data.actor.width*(data.actor.data['health']);
			}
			else
			{
				data.healthBarFill.visible = false;
			}
			data.healthBarFill.x = actor.x;
			data.healthBarFill.y = actor.y - 1;
			
		}
		if (data.healthBar != null)
		{
			data.healthBar.x = actor.x;
			data.healthBar.y = actor.y - 1;
		}
		if (actor.data['health'] <= 0)
		{
			kill();
		}
	}
	
	public function createSprite()
	{			
		data.healthBar = new Object(object.x, object.y, Polygon.createRectangle(actor.width, 1, Color.Red, true));
		data.p = Polygon.createRectangle(data.actor.width, 1, Color.Green, true);
		data.healthBarFill = new Object(object.x, object.y, data.p);
		sdg.Sdg.screen.add(data.healthBar);
		sdg.Sdg.screen.add(data.healthBarFill);
	}
	
	public function kill(e:EventObject = null)
	{
		
		object.screen.remove(data.healthBar);
		object.screen.remove(data.healthBarFill);
		
		actor.kill();
		object.eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
		object.screen.remove(object, true);
	}
}
