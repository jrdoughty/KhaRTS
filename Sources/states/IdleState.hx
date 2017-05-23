package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;


class IdleState extends BaseState
{

	public override function takeAction()
	{	
		if(actor.data['targetNode'] == null && actor.data['targetEnemy'] == null)
		{
			checkView();
			actor.data['targetEnemy'] = getEnemyInThreat();
		}

		if (actor.data['targetNode'] != null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(MOVING, true));
		}
		else if (actor.data['targetEnemy'] != null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(ATTACKING));
		} 
		else
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
	}
	
}