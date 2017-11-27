package states;

import actors.Actor;
import events.StateChangeEvent;
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


class GatherState extends ResourceState
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
		actor.data['resourcesCollected'] = 0;
	}

	public override function enter()
	{
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
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('gathering'));
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
}