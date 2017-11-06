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

		if (actor.data['targetNode'] != null && actor.data['mobile'])
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('moving', true));
		}
		else if (actor.data['targetEnemy'] != null && actor.data['targetEnemy'].data.exists('health'))
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('attacking'));
		} 
		else
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
	}
	
}