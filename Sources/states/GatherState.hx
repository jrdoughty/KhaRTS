package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.MoveAnimEvent;
import world.Node;
import systems.AStar;
import events.StopEvent;
import tween.Delta;
import events.AnimateAttackEvent;
import events.HurtEvent;
import events.GatherEvent;


class GatherState extends MovingState
{
	var finishedResource:Bool = false;
	public function new(a:Actor)
	{
		super(a);
		
		if(a.data.exists('resources'))
			a.eventDispatcher.addEvent(GatherEvent.GATHER, TargetActor);
		else
			trace('can\'t harvest');
		a.eventDispatcher.addEvent(StopEvent.STOP, resetData);
	}

	public override function enter()
	{
		if(actor.coolDown != actor.data['moveCoolDown'])
			actor.coolDown = actor.data['moveCoolDown'];
	}

	public override function takeAction()
	{	
		if (actor.data['targetResource'] != null)
		{
			if (Util.getPythagoreanCFromXY(cast(actor.data['targetResource'], Actor).currentNodes[0].nodeX,cast(actor.data['targetResource'], Actor).currentNodes[0].nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
			{
				gather();
			}
			else if(actor.data['mobile'])
			{
				chase();
			}
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}

	/**
	 * similar to move function except more complicated, as it needs to determine if the 
	 * targetResource has moved and adjust if it has. May merge with Move Eventually
	 */
	private function chase()
	{		
		actor.coolDown = actor.data['moveCooldown'];

		if (path.length == 0 || path[path.length - 1] != actor.data['targetResource'].currentNodes[0])
		{
			path = AStar.newPath(actor.currentNodes[0], actor.data['targetResource'].currentNodes[0]);
		}
		
		if (path.length > 1 && path[1].occupant == null)
		{
			moveAlongPath();
		}
		else
		{
			if(actor.data['targetNode'] == null && actor.data['targetResource'] != null)
			{
				actor.data['targetNode'] = cast(actor.data['targetResource'], Actor).currentNodes[0];
			}
			newPath();
		}

		if (failedToMove)
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
		}
	}
	
	private function gather()
	{
		trace('collecting');
	}
	
	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(gEvent:GatherEvent)
	{
		actor.eventDispatcher.dispatchEvent(StopEvent.STOP, new StopEvent());
		actor.data['targetResource'] = gEvent.target;
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('gathering'));
	}
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:StopEvent = null):Void 
	{
		actor.data.set('targetResource', null);
	}
}