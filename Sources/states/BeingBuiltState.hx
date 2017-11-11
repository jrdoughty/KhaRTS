package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.BuildEvent;
import kha.Scheduler;


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