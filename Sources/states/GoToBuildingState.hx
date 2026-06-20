package states;

import actors.Actor;
import events.StateChangeEvent;
import world.Node;
import sdg.pathfinding.INode;
import sdg.pathfinding.AStar;
import events.SimpleEvents;
import tween.Delta;
import events.AnimateEvent;
import events.HurtEvent;
import events.SetBuildingEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import events.GatherEvent;
import screens.IGameScreen;
import systems.Data.Buildings;
import events.BuildAtEvent;


class GoToBuildingState extends MovingState
{
	public function new(a:Actor)
	{
		super(a);
		
		a.eventDispatcher.addEvent(BuildAtEvent.BUILD, BuildAt);
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
	}

	public override function enter()
	{
		actor.coolDown = actor.data.moveCoolDown;
		trace('build damn it!');
	}

	public override function takeAction()
	{	
		if (actor.targetNode != null)
		{
			var bn = cast(actor.buildNode, Node);
			if (Util.getPythagoreanCFromXY(actor.targetNode.nodeX,actor.targetNode.nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
			{
				if(bn.occupant != null && bn.occupant.buildingData.name == actor.buildData.name)
				{
					actor.eventDispatcher.dispatchEvent(SetBuildingEvent.BUILD_ACTOR, new SetBuildingEvent(bn.occupant));
				}
				else
				{
					trace(actor.buildData);
					var act = new Actor(bn, actor.buildData);
					trace('after');
					actor.screen.add(actor.team.addBuilding(act));
					actor.eventDispatcher.dispatchEvent(SetBuildingEvent.BUILD_ACTOR, new SetBuildingEvent(act));
				}
			}
			else if(actor.data.mobile)
			{
				move();
			}
			else
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
			}
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}


	private function move()
	{		
		actor.coolDown = actor.data.moveCoolDown;

		if (path.length == 0 || path[path.length - 1] != actor.targetNode)
		{
			path = AStar.newPath(actor.currentNodes[0], actor.targetNode);
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
				newPath();
			}
		}
		
		animateMove();
	}
	

	public function BuildAt(bEvent:BuildAtEvent)
	{
		if(bEvent.node == null)
		{
			trace('targetting a null resource');
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(SimpleEvents.STOP, new EventObject());
			actor.buildNode = bEvent.node;
			
			var w = (Math.ceil(actor.buildData.width/bEvent.node.width));
			var h = (Math.ceil(actor.buildData.height/bEvent.node.height));
			var paths:Array<Array<INode>> = [];
			for(i in 0...w)
			{
				for(j in 0...h)
				{
					var gs = cast (actor.screen, screens.IGameScreen);
					var p = AStar.newPath(actor.currentNodes[0], gs.lvl.getNodeByGridXY(bEvent.node.nodeX + i, bEvent.node.nodeY + j));
					if(p.length > 0)
						paths.push(p);
				}
			}
			for(i in paths)
			{
				if(i.length < path.length || path.length == 0)
				{
					path = i;
					actor.targetNode = path[path.length-1];
				}
			}


			actor.buildData = actor.buildData;
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('go_to_building'));
		}
	} 

	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:EventObject = null):Void 
	{
		actor.targetNode = null;
		actor.buildNode = null;
		path = [];
	}
}