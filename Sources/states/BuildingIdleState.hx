package states;

import events.IdleAnimationEvent;
import events.BuildEvent;


class BuildingIdleState extends BaseState
{
	var needsBuilt:Bool = true;

	public override function enter()
	{
		if(needsBuilt)
		{
			needsBuilt = false;
			actor.eventDispatcher.dispatchEvent(BuildEvent.BUILD, new BuildEvent());
		}
		else
		{
			actor.coolDown = 1000;
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
	}

	public override function takeAction()
	{	
		
	}
	
}