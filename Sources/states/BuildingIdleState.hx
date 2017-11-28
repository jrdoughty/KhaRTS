package states;

import events.AnimateEvent;
import events.SimpleEvents;
import sdg.event.EventObject;


class BuildingIdleState extends BaseState
{
	var needsBuilt:Bool = true;

	public override function enter()
	{
		if(needsBuilt)
		{
			needsBuilt = false;
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