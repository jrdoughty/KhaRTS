package states;

import actors.Actor;
import events.StateChangeEvent;
import sdg.pathfinding.AStar;
import events.SimpleEvents;
import events.AnimateEvent;
import events.KillEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import world.Node;


class GatherState extends BaseState
{
	var finishedResource:Bool = false;

	public function new(a:Actor)
	{
		super(a);
		
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
		actor.currentResource = null;
		actor.resourcesCollected = 0;
	}

	public override function enter()
	{
		for(i in actor.data.resources)
		{
			var rf = i.name;
			if(actor.currentResource == rf.name)
			{
				actor.coolDown = i.coolDown;
				break;
			}
		}
		if(!cast(actor.targetResource, Actor).alive)
		{
			actor.targetResource = findNewResource();
		}
		if(actor.targetResource == null)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
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

	public override function takeAction()
	{	
		if(actor.targetResource == null || !actor.targetResource.alive)
		{
			actor.targetResource = findNewResource();
		}
		if (actor.targetResource != null)
		{
			var tRes = actor.targetResource;
			if (Util.getPythagoreanCFromXY(tRes.currentNodes[0].nodeX,tRes.currentNodes[0].nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
			{
				gather();
			}
			else if(actor.data.mobile)
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('go_to_resource', true));
			}
			else
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
			}
		}
		else
		{
			if(actor.resourcesCollected>0)
			{
				actor.eventDispatcher.dispatchEvent(SimpleEvents.RETURN, new EventObject());
			}
			else
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
			}
		}
	}

	private function gather()
	{
		var tRes:Actor = actor.targetResource;
		actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('gather',false));
		if(actor.currentResource == null)
		{
			actor.resourcesCollected = 0;
			var rf=tRes.resourceData.resource;
			actor.currentResource = rf.name;
		}
		
		for(i in actor.data.resources)
		{
			var rf = i.name;
			if(actor.currentResource == rf.name)
			{
				var amtToHarvest = i.harvest + actor.resourcesCollected > i.maxHarvest ? i.maxHarvest - actor.resourcesCollected:i.harvest;
				if(amtToHarvest >= tRes.value)
				{
					actor.resourcesCollected += tRes.value;
					tRes.value = 0; 
				}
				else
				{
					actor.resourcesCollected += amtToHarvest;
					tRes.value -= amtToHarvest;
				}
				if(tRes.value == 0)
				{
					var e = new KillEvent(actor);
					e.bubble = false;
					actor.targetResource.eventDispatcher.dispatchEvent(KillEvent.KILL, e);
				}
				
				if(actor.resourcesCollected == i.maxHarvest)
				{
					actor.eventDispatcher.dispatchEvent(SimpleEvents.RETURN, new EventObject());
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