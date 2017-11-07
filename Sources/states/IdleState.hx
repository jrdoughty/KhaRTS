package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;


class IdleState extends BaseState
{

	public override function enter()
	{
		if(actor.coolDown != actor.data['idleCoolDown'])
			actor.coolDown = actor.data['idleCoolDown'];
	}

	public override function takeAction()
	{	
		if(actor.data['targetNode'] == null && actor.data['targetEnemy'] == null)
		{
			checkView();
			actor.data['targetEnemy'] = getEnemyInThreat();
		}
		actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
	}
	
}