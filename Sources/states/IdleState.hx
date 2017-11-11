package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.TargetEvent;


class IdleState extends BaseState
{

	public override function enter()
	{
		if(actor.coolDown != actor.data['idleCoolDown'])
			actor.coolDown = actor.data['idleCoolDown'];
		actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
	}

	public override function takeAction()
	{
			checkView();
			var enemy = getEnemyInThreat();
			if(enemy != null)
				actor.eventDispatcher.dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(enemy));
	}
	
}