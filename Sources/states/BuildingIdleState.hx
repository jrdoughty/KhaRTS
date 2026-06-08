package states;

import events.AnimateEvent;
import events.SimpleEvents;
import sdg.event.EventObject;


class BuildingIdleState extends BaseState
{

	public override function enter()
	{
		if(actor.value < 10)
		{
			actor.eventDispatcher.dispatchEvent(SimpleEvents.BUILD, new EventObject());
		}
		else
		{
			actor.coolDown = 1000;
			actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle', true));
		}
	}

	public override function takeAction()
	{	
		
	}
	
}