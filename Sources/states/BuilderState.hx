package states;

import events.AnimateEvent;
import events.SimpleEvents;
import sdg.event.EventObject;


class BuildingIdleState extends BaseState
{
	var needsBuilt:Bool = true;

	public override function enter()
	{
		actor.coolDown = 1000;
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle'));
	}

	public override function takeAction()
	{	
		actor.eventDispatcher.dispatchEvent(SimpleEvents.BUILD_PROGRESS, new EventObject());
		if(actor.data['targetActor'].data['built'] == true)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
	}
	
}