package states;

import events.IdleAnimationEvent;
import events.StateChangeEvent;


class WanderState extends BaseState
{

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
			if(Math.random() < .5)
			{
				actor.data['targetNode'] = actor.neighbors[Math.floor(Math.random() * actor.neighbors.length)];
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('moving', true));
			}
			else
				actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
	}
	
}