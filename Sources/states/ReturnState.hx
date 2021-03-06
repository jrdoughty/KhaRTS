package states;

import events.AnimateEvent;
import actors.Actor;
import events.StateChangeEvent;
import world.Node;
import systems.AStar;
import sdg.event.EventObject;
import tween.Delta;
import events.GatherEvent;
import events.SimpleEvents;


class ReturnState extends MovingState
{
	var finishedResource:Bool = false;
	public function new(a:Actor)
	{
		super(a);
		
		if(a.data.exists('resources'))
			a.eventDispatcher.addEvent(SimpleEvents.RETURN, returnResources);
		else
			trace('can\'t harvest');
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
		actor.data['currentResource'] = null;
	}

	public override function enter()
	{
		path = findClosestBuilding();
		if(path.length == 0)
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
		else
		{
			actor.data['targetNode'] = path[path.length-1];
			if(actor.coolDown != actor.data['moveCoolDown'])
				actor.coolDown = actor.data['moveCoolDown'];
		}
	}

	public override function takeAction()
	{	
		if (path.length == 2)
		{
			actor.team.resources += actor.data['resourcesCollected'];
			actor.data['resourcesCollected'] = 0;
			actor.eventDispatcher.dispatchEvent(GatherEvent.GATHER, new GatherEvent(actor.data['targetResource']));
		}
		else if (actor.data['resourcesCollected'] > 0)
		{
			move();
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}

	
	private function move()
	{		
		actor.coolDown = actor.data['moveCoolDown'];

		if (path.length == 0)
		{
			path = findClosestBuilding();
			actor.data['targetNode'] = path[path.length-1];
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
		
		animateMove();
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

	private function findClosestBuilding()
	{
		var pathsToReturn:Array<Array<Node>> = [];

		for(i in actor.team.units)
		{
			if(i.data['resourcesAccepted'] != null)
			{
				var rA:Array<Dynamic> = i.data['resourcesAccepted'];
				for(j in rA)
				{
					if(j.name == actor.data['currentResource'])
					{
						for(k in i.currentNodes)
						{
							pathsToReturn.push(AStar.newPath(actor.currentNodes[0], k));
						}
					}
				}
			}
		}

		var bestIndex:Int = 0;
		var bestVal:Null<Int> = null;
		for(i in 0...pathsToReturn.length)
		{
			if(bestVal == null || bestVal > pathsToReturn[i].length)
			{
				bestVal = pathsToReturn[i].length;
				bestIndex = i;
			}
		}
		if(pathsToReturn[bestIndex] == null)
			return [];
		return pathsToReturn[bestIndex];
	}
	

	public function returnResources(e:EventObject)
	{
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('returning'));
	}
}