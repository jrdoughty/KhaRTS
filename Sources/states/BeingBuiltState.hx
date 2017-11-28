package states;

import actors.Actor;
import events.StateChangeEvent;
import events.SimpleEvents;
import kha.Scheduler;
import events.AnimateEvent;
import sdg.event.EventObject;


class BeingBuiltState extends BaseState
{

	public function new(a:Actor)
	{
		super(a);
		a.eventDispatcher.addEvent(SimpleEvents.BUILD, build);
	}
	public override function enter()
	{
		actor.coolDown = 1000;
		
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('building', true));
		Scheduler.addTimeTask(finishBuild,1,0,1);//actor.data['buildTime']);
	}

	private function build(e:EventObject)
	{
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('being_built',true));
	}

	private function finishBuild()
	{
		trace('finished');
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle',true));
	}
}