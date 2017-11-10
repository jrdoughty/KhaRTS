package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;


class BuildingIdleState extends BaseState
{

	public override function enter()
	{
		actor.coolDown = 1000;
		actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
	}

	public override function takeAction()
	{	
		
	}
	
}