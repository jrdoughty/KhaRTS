package states;

import events.AnimateEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import events.StateChangeEvent;
import actors.Actor;

class Builder extends BaseState
{
	var needsBuilt:Bool = true;

	public override function enter()
	{
		actor.coolDown = 1000;
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('build'));
	}

	public override function takeAction()
	{	
		actor.eventDispatcher.dispatchEvent(SimpleEvents.BUILD_PROGRESS, new EventObject());
		var tBuild:Actor = actor.data['targetBuilding'];
		if(tBuild.data['built'] == true)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
	}	

	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:TargetEvent)
	{
		actor.eventDispatcher.dispatchEvent(SimpleEvents.STOP, new EventObject());
		actor.data['targetActor'] = aEvent.target;
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('attacking'));
	}
	
}