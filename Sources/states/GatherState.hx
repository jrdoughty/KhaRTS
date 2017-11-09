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
import events.KillEvent;
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
		actor.data['currentResource'] = null;
	}

	public override function enter()
	{
		if(actor.coolDown != actor.data['moveCoolDown'])
			actor.coolDown = actor.data['moveCoolDown'];
	}

	public override function takeAction()
	{	
		var tRes = cast(actor.data['targetResource'], Actor);
		if (actor.data['targetResource'] != null)
		{
			if (Util.getPythagoreanCFromXY(tRes.currentNodes[0].nodeX,tRes.currentNodes[0].nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
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
		var tRes:Actor = cast(actor.data['targetResource'], Actor);
		if(actor.data['currentResource'] == null || actor.data['currentResource'] != tRes.data['resource'])
		{
			actor.data['resourcesCollected'] = 0;
			actor.data['currentResource'] = tRes.data['resource'];
		}
		var resources:Array<Dynamic> = actor.data['resources'];
		for(i in resources)
		{
			if(actor.data['currentResource'] == i.name)
			{
				if(i.harvest >= tRes.data['resourceValue'])
				{
					actor.data['resourcesCollected'] += tRes.data['resourceValue'];
					tRes.data['resourceValue'] = 0; 
				}
				else
				{
					actor.data['resourcesCollected'] += i.harvest;
					tRes.data['resourceValue'] -= i.harvest;
				}
				if(tRes.data['resourceValue'] == 0)
				{
					actor.data['targetResource'].eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
				}
				actor.coolDown = i.coolDown;
			}
		}
		
	}
	
	/**
	 * sets target to start either gather or chase sequence
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

	private function returnResources()
	{
		var pathsToReturn:Array<Array<Node>> = [];
		for(i in actor.team.units)
		{
			if(i.data['resourcesAccepted'] != null)
			{
				var rA:Array<Dynamic> = i.data['resourcesAccepted'];
				for(i in rA)
				{
					var resources:Array<Dynamic> = actor.data['resources'];
					for(j in resources)
					{
						if(i.name == j.name)
						{

						}
					}
				}
			}
		}
	}
}