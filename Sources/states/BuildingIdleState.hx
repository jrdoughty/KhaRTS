package states;

import events.AnimateEvent;
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
			actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle', true));
		}
	}

	public override function takeAction()
	{	
		
	}
	
}