package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.MoveAnimEvent;
import world.Node;
import systems.AStar;
import events.StopEvent;
import tween.Delta;
import events.AnimateEvent;
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
		actor.data['resourcesCollected'] = 0;
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
		else
		{
			actor.data['targetNode'] = cast(actor.data['targetResource'], Actor).currentNodes[0];
			if(actor.data['currentResource'] != cast(actor.data['targetResource'], Actor).data['resource'])
			{
				actor.data['resourcesCollected'] = 0;
			}
			actor.data['currentResource'] = cast(actor.data['targetResource'], Actor).data['resource'];
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
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
			}
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
			newPath();
			if(failedToMove)
			{
				failedToMove = false;
				actor.data['targetResource'] = findNewResource();
				if(actor.data['targetResource'] == null)
				{
					if(actor.data['resourcesCollected']>0)
					{
						actor.eventDispatcher.dispatchEvent(ReturnEvent.RETURN, new ReturnEvent());
					}
					else
					{
						actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
					}
				}
				else
				{
					newPath();
				}
			}
		}
		
		animateMove();
	}
	private override function newPath()
	{
		var nextMove = path[1];
		path = AStar.newPath(actor.currentNodes[0], actor.data['targetResource'].currentNodes[0]);
		if (path.length > 1 && nextMove != path[1])//In Plain english, if the new path is indeed a new path
		{
			takeAction();//try again
		}
		else
		{
			failedToMove = true;
		}
	}

	private function gather()
	{
		var tRes:Actor = cast(actor.data['targetResource'], Actor);
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('gather',false));
		if(actor.data['currentResource'] == null)
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
			trace('targetting a null resource');
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

	/**
	* could use some efficiency by only scanning the perimiter
	*/
	private function findNewResource():Actor
	{
		var openList:Array<Node> = actor.currentNodes[0].neighbors;
		var closeList:Array<Node> = [actor.currentNodes[0]];
		var iterationsAllowed = 6;
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
					if(openList.indexOf(j) == -1 && closeList.indexOf(j) == -1 && nextOpenList.indexOf(j) == -1)
					{
						nextOpenList.push(j);
					}
				}
				closeList.push(i);
			}
			openList = nextOpenList;
		}
		trace('nulled');
		return null;
	}
}