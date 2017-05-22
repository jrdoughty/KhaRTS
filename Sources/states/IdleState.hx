package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;


class IdleState extends BaseState
{

	public override function takeAction()
	{	
		if (actor.data['targetNode'] != null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(MOVING, true));
		}
		else if (actor.data['targetEnemy'] != null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(ATTACKING, true));
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
	}
	
}