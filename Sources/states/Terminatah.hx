package states;

import events.AnimateEvent;
import events.StateChangeEvent;


class Terminatah extends BaseState
{

	public override function takeAction()
	{	
		if(actor.targetNode == null && actor.targetEnemy == null)
		{
			checkView();
			actor.targetEnemy = getEnemyInThreat();
		}

		if (actor.targetNode != null && actor.data.mobile)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('moving', true));
		}
		else if (actor.targetEnemy != null && actor.targetEnemy.data != null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('attacking'));
		} 
		else
		{
			if(Math.random() <.5)
			{
				actor.targetNode = actor.currentNodes[0].neighbors[Math.floor(Math.random() * actor.currentNodes[0].neighbors.length)];
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('moving', true));
			}
			else
				actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle', true));
		}
	}
	
}