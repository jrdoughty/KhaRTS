package states;

import events.AnimateEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import events.StateChangeEvent;
import actors.Actor;
import events.SetBuildingEvent;

class BuilderState extends BaseState
{
	var needsBuilt:Bool = true;

	public function new(a:Actor)
	{
		super(a);
		
		a.eventDispatcher.addEvent(SetBuildingEvent.BUILD_ACTOR, TargetActor);
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
	}

	public override function enter()
	{
		actor.coolDown = 1000;
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('build'));
	}

	public override function takeAction()
	{	
			trace('working');
		var tBuild:Actor = actor.data['targetBuilding'];
		tBuild.eventDispatcher.dispatchEvent(SimpleEvents.BUILD_PROGRESS, new EventObject());
		if(tBuild.data['built'] == true)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
	}	
	
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:EventObject = null):Void 
	{
		actor.data.set('targetBuilding', null);
	}

	/**
	 * sets target to start either builder state or a chase state
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:SetBuildingEvent)
	{
		if(!aEvent.target.data['built'])
		{
			trace('working');
			actor.eventDispatcher.dispatchEvent(SimpleEvents.STOP, new EventObject());
			actor.data['targetBuilding'] = aEvent.target;
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('builder'));
		}
		else
		{
			trace('why build what is built');
		}
	}
	
}