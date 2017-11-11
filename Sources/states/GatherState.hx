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
import events.ReturnEvent;
import events.GatherEvent;
import screens.IGameScreen;


class GatherState extends MovingState
{
	var finishedResource:Bool = false;
	var lastResourceX:Int = -1;
	var lastResourceY:Int = -1;
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
		if(!cast(actor.data['targetResource'], Actor).alive)
		{
			actor.data['targetResource'] = findNewResource();
		}
		if(actor.data['targetResource'] == null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
	}

	public override function takeAction()
	{	
		if(actor.data['targetResource'] == null || !cast(actor.data['targetResource'], Actor).alive)
		{
			actor.data['targetResource'] = findNewResource();
		}
		if (actor.data['targetResource'] != null)
		{
			var tRes = cast(actor.data['targetResource'], Actor);
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
			if(actor.data['resourcesCollected'])
			{
				actor.eventDispatcher.dispatchEvent(ReturnEvent.RETURN, new ReturnEvent());
			}
			else
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}

	/**
	 * similar to move function except more complicated, as it needs to determine if the 
	 * targetResource has moved and adjust if it has. May merge with Move Eventually
	 */
	private function chase()
	{		
		actor.coolDown = actor.data['moveCoolDown'];

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
		actor.eventDispatcher.dispatchEvent(AnimateAttackEvent.ATTACK, new AnimateAttackEvent());
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
				var amtToHarvest = i.harvest + actor.data['resourcesCollected'] > i.harvestMax ? i.harvestmax - actor.data['resourcesCollected']:i.harvest;
				if(amtToHarvest >= tRes.data['resourceValue'])
				{
					actor.data['resourcesCollected'] += tRes.data['resourceValue'];
					tRes.data['resourceValue'] = 0; 
				}
				else
				{
					actor.data['resourcesCollected'] += amtToHarvest;
					tRes.data['resourceValue'] -= amtToHarvest;
				}
				if(tRes.data['resourceValue'] == 0)
				{
					var e = new KillEvent(actor);
					e.bubble = false;
					actor.data['targetResource'].eventDispatcher.dispatchEvent(KillEvent.KILL, e);
				}
				trace('collect '+actor.data['resourcesCollected']);
				trace(i.maxHarvest);
				if(actor.data['resourcesCollected'] == i.maxHarvest)
				{
					actor.eventDispatcher.dispatchEvent(ReturnEvent.RETURN, new ReturnEvent());
				}
				else
				{
					actor.coolDown = i.coolDown;
				}
				break;
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
		
		if(gEvent.target == null)
		{
			actor.data['targetResource'] = findNewResource();
		}
		else
		{
			actor.data['targetResource'] = gEvent.target;
		}
		if(actor.data['targetResource'] != null)
		{
			lastResourceX = gEvent.target.currentNodes[0].nodeX;
			lastResourceY = gEvent.target.currentNodes[0].nodeY;
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('gathering'));
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
		
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

	private function findNewResource():Actor
	{
		var openList:Array<Node> = cast(actor.screen, IGameScreen).lvl.getNodeByGridXY(lastResourceX, lastResourceY).neighbors;
		var closeList:Array<Node> = [];
		var iterationsAllowed = 5;
		var i = 0;
		while(openList.length > 0 && i < iterationsAllowed)
		{
			i++;
			for(i in openList)
			{
				if(i.occupant != null && i.occupant.data['resource'] != null && i.occupant.data['resource'] == actor.data['currentResource'])
				{
					return i.occupant;
				}
			}
			var nextOpenList:Array<Node> = [];
			for(i in openList)
			{
				for(j in i.neighbors)
				{
					if(openList.indexOf(j) == -1 && closeList.indexOf(j) == -1)
					{
						nextOpenList.push(j);
					}
				}
				closeList.push(i);
			}
			openList = nextOpenList;
		}
		return null;
	}
}