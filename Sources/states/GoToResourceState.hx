package states;

import actors.Actor;
import events.StateChangeEvent;
import world.Node;
import sdg.pathfinding.AStar;
import events.SimpleEvents;
import tween.Delta;
import events.AnimateEvent;
import events.HurtEvent;
import events.KillEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import events.GatherEvent;
import screens.IGameScreen;


class GoToResourceState extends MovingState
{
	var finishedResource:Bool = false;
	public function new(a:Actor)
	{
		super(a);
		
		if(a.data.resources.length>0)
			a.eventDispatcher.addEvent(GatherEvent.GATHER, TargetActor);
		else
			trace('can\'t harvest');
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
		actor.currentResource = null;
		actor.resourcesCollected = 0;
	}

	public override function enter()
	{
		actor.coolDown = actor.data.moveCoolDown;
		if(actor.targetResource == null)
		{
			trace('go to resource broke');
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
		else
		{
			if(!cast(actor.targetResource, Actor).alive)
			{
				actor.targetResource = findNewResource();
			}
			if(actor.targetResource == null)
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
			}
			else
			{
				actor.targetNode = cast(actor.targetResource, Actor).currentNodes[0];
				var rf = actor.targetResource.resourceData.resource;
				if(actor.currentResource != rf.name)
				{
					actor.resourcesCollected = 0;
				}
				actor.currentResource = rf.name;
			}
		}
	}

	public override function takeAction()
	{	
		if(actor.targetResource == null || !cast(actor.targetResource, Actor).alive)
		{
			actor.targetResource = findNewResource();
		}
		if (actor.targetResource != null)
		{
			var tRes = cast(actor.targetResource, Actor);
			if (Util.getPythagoreanCFromXY(tRes.currentNodes[0].nodeX,tRes.currentNodes[0].nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('gathering', true));
			}
			else if(actor.data.mobile)
			{
				chase();
			}
			else
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
			}
		}
		else
		{
			if(actor.resourcesCollected > 0)
			{
				actor.eventDispatcher.dispatchEvent(SimpleEvents.RETURN, new EventObject());
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
		actor.coolDown = actor.data.moveCoolDown;

		if (path.length == 0 || path[path.length - 1] != actor.targetResource.currentNodes[0])
		{
			path = AStar.newPath(actor.currentNodes[0], actor.targetResource.currentNodes[0]);
		}
		
		if (path.length > 1 && path[1].isPassible())
		{
			moveAlongPath();
		}
		else
		{
			newPath();
			if(failedToMove)
			{
				failedToMove = false;
				actor.targetResource = findNewResource();
				if(actor.targetResource == null)
				{
					if(actor.resourcesCollected>0)
					{
						actor.eventDispatcher.dispatchEvent(SimpleEvents.RETURN, new EventObject());
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
	
	/**
	 * sets target to start either gather or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(gEvent:GatherEvent)
	{
		if(gEvent.target == null)
		{
			trace('targetting a null resource');
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(SimpleEvents.STOP, new EventObject());
			actor.targetResource = gEvent.target;
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('gathering'));
		}
	}

	private override function newPath()
	{
		var nextMove = path[1];
		path = AStar.newPath(actor.currentNodes[0], actor.targetResource.currentNodes[0]);
		if (path.length > 1 && nextMove != path[1])//In Plain english, if the new path is indeed a new path
		{
			takeAction();//try again
		}
		else
		{
			failedToMove = true;
		}
	}
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:EventObject = null):Void 
	{
		actor.targetResource = null;
	}

	/**
	* could use some efficiency by only scanning the perimiter
	*/
	
	private function findNewResource():Actor
	{
		var openList:Array<Node> = actor.currentNodes[0].getNodeNeighbors();
		var closeList:Array<Node> = [actor.currentNodes[0]];
		var iterationsAllowed = 6;
		var i = 0;
		while(openList.length > 0 && i < iterationsAllowed)
		{
			i++;
			for(j in openList)
			{
				if(j.occupant != null && j.occupant.resourceData != null && j.occupant.resourceData.resource != null)
				{
					var rf = j.occupant.resourceData.resource;
					if(rf.name == actor.currentResource)
					{
						return j.occupant;
					}
				}
			}
			var nextOpenList:Array<Node> = [];
			for(k in openList)
			{
				for(j in k.getNodeNeighbors())
				{
					if(openList.indexOf(j) == -1 && closeList.indexOf(j) == -1 && nextOpenList.indexOf(j) == -1)
					{
						nextOpenList.push(j);
					}
				}
				closeList.push(k);
			}
			openList = nextOpenList;
		}
		trace('nulled');
		return null;
	}
}