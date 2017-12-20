package states;

import actors.Actor;
import events.StateChangeEvent;
import systems.AStar;
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
		actor.data['currentResource'] = null;
		actor.data['resourcesCollected'] = 0;
	}

	public override function enter()
	{
		var resources:Array<Dynamic> = actor.data['resources'];
		for(i in resources)
		{
			if(actor.data['currentResource'] == i.name)
			{
				actor.coolDown = i.coolDown;
				break;
			}
		}
		if(!cast(actor.data['targetResource'], Actor).alive)
		{
			actor.data['targetResource'] = findNewResource();
		}
		if(actor.data['targetResource'] == null)
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
		actor.data.set('targetResource', null);
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
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('go_to_resource', true));
			}
			else
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
			}
		}
		else
		{
			if(actor.data['resourcesCollected'])
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