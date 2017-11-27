package states;

import actors.Actor;
import events.StateChangeEvent;
import events.BuildEvent;
import kha.Scheduler;
import events.AnimateEvent;


class BeingBuiltState extends BaseState
{

	public function new(a:Actor)
	{
		super(a);
		a.eventDispatcher.addEvent(BuildEvent.BUILD, build);
	}
	public override function enter()
	{
		actor.coolDown = 1000;
		
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('building', true));
		Scheduler.addTimeTask(finishBuild,1,0,1);//actor.data['buildTime']);
	}

	private function build(e:BuildEvent)
	{
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('being_built',true));
	}

	private function finishBuild()
	{
		trace('finished');
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle',true));
	}
}