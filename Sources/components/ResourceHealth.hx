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
class ResourceHealth extends ActorComponent
{
	public function new() 
	{
		super();
	}
	
	override public function init() 
	{
		super.init();
		object.eventDispatcher.addEvent(HurtEvent.HURT, hurt);
		object.eventDispatcher.addEvent(KillEvent.KILL, kill);	
		for(i in actor.currentNodes)
		{
			i.hasResource = true;
		}
	}
	
	public function hurt(e:HurtEvent)
	{
		
			actor.data['health'] -= e.damage / actor.data['healthMax'];
	}
	
	/**
	 * keeps up the position of the health bar, and maintains the fill
	 */
	public override function update()
	{
		super.update();
		
		if (actor.data['health'] <= 0)
		{
			kill();
		}
	}
	
	public function kill(e:EventObject = null)
	{		
		for(i in actor.currentNodes)
		{
			i.hasResource = false;
		}
		actor.kill();
		if(e==null)
			actor.eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
		actor.alive = false;
		actor.screen.remove(object, true);
		
	}
}
