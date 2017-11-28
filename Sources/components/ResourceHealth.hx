package components;

import sdg.event.EventObject;
import events.KillEvent;
import events.HurtEvent;
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
