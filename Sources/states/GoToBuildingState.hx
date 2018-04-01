package states;

import actors.Actor;
import events.StateChangeEvent;
import world.Node;
import systems.AStar;
import events.SimpleEvents;
import tween.Delta;
import events.AnimateEvent;
import events.HurtEvent;
import events.SetBuildingEvent;
import events.SimpleEvents;
import sdg.event.EventObject;
import events.GatherEvent;
import screens.IGameScreen;
import events.BuildAtEvent;


class GoToBuildingState extends MovingState
{
	private var bData:Map<String,Dynamic>;
	public function new(a:Actor)
	{
		super(a);
		
		a.eventDispatcher.addEvent(BuildAtEvent.BUILD, BuildAt);
		a.eventDispatcher.addEvent(SimpleEvents.STOP, resetData);
	}

	public override function enter()
	{
		actor.coolDown = actor.data['moveCoolDown'];
		trace('build damn it!');
	}

	public override function takeAction()
	{	
		if (actor.data['targetNode'] != null)
		{
			if (Util.getPythagoreanCFromXY(actor.data['targetNode'].nodeX,actor.data['targetNode'].nodeY, actor.currentNodes[0].nodeX, actor.currentNodes[0].nodeY)<=Math.sqrt(2))
			{
				if(cast(actor.data['buildNode'], Node).occupant != null && cast(actor.data['buildNode'], Node).occupant.data['name'] == bData['name'])
				{
					actor.eventDispatcher.dispatchEvent(SetBuildingEvent.BUILD_ACTOR, new SetBuildingEvent(cast(actor.data['buildNode'], Node).occupant));
				}
				else
				{
					var act = new Actor(actor.data['buildNode'], Util.cloneStringMap(bData));
					actor.screen.add(actor.team.addUnit(act));
					actor.eventDispatcher.dispatchEvent(SetBuildingEvent.BUILD_ACTOR, new SetBuildingEvent(act));
				}
			}
			else if(actor.data['mobile'])
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
		actor.coolDown = actor.data['moveCoolDown'];

		if (path.length == 0 || path[path.length - 1] != actor.data['targetNode'])
		{
			path = AStar.newPath(actor.currentNodes[0], actor.data['targetNode']);
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
			actor.data['buildNode'] = bEvent.node;
			
			var w = (Math.ceil(bEvent.bData['width']/bEvent.node.width));
			var h = (Math.ceil(bEvent.bData['height']/bEvent.node.height));
			var paths:Array<Array<Node>> = [];
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
					actor.data['targetNode'] = path[path.length-1];
				}
			}


			bData = bEvent.bData;
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
		actor.data.set('targetNode', null);
		actor.data.set('buildNode', null);
		path = [];
	}
}