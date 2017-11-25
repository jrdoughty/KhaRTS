package states;

import events.AnimateEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.TargetEvent;


class IdleState extends BaseState
{

	public override function enter()
	{
		if(actor.coolDown != actor.data['idleCoolDown'])
			actor.coolDown = actor.data['idleCoolDown'];
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle',true));
	}

	public override function takeAction()
	{
			checkView();
			var enemy = getEnemyInThreat();
			if(enemy != null)
				actor.eventDispatcher.dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(enemy));
	}
	
}