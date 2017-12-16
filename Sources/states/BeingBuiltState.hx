package states;

import actors.Actor;
import events.StateChangeEvent;
import events.SimpleEvents;
import kha.Scheduler;
import events.AnimateEvent;
import sdg.event.EventObject;


class BeingBuiltState extends BaseState
{
	/**
	* Build Progress in seconds
	*/
	var progress:Int = 0;
	var tID:Int;
	public function new(a:Actor)
	{
		super(a);
		a.eventDispatcher.addEvent(SimpleEvents.BUILD, startBuild);
	}
	public override function enter()
	{
		actor.coolDown = 1000;
		
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('building', true));
	}

	private function startBuild(e:EventObject)
	{
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('being_built',true));
		actor.eventDispatcher.addEvent(SimpleEvents.BUILD_PROGRESS, build);
	}

	private function build(e:EventObject)
	{
		progress++;
		if(progress == 10)
		{
			finishBuild();
		}
	}

	private function finishBuild()
	{
		actor.data['built'] = true;
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle',true));
		actor.eventDispatcher.removeEvent(SimpleEvents.BUILD_PROGRESS, build);
	}
}