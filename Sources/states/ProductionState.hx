package states;

import events.IdleAnimationEvent;
import actors.Actor;
import events.StateChangeEvent;
import events.QueueEvent;
import systems.Data;
import world.Node;


class ProductionState extends BaseState
{

	public function new(a:Actor)
	{
		super(a);
		
		actor.data['queue'] = new Array<UnitData>();
		actor.eventDispatcher.addEvent(QueueEvent.QUEUE, QueueUnitAction);
		//a.eventDispatcher.addEvent(StopEvent.STOP, resetData);
	}

	public override function enter()
	{
		actor.coolDown = 250;//displays such as meters will be updated every quarter sec
	}

	public override function takeAction()
	{	
		trace('wat');
	}

	private function QueueUnitAction(e:QueueEvent)
	{
		actor.data['queue'].push(e.uData);
		if(e.uData.cost <= actor.team.resources)
		{
			actor.team.resources -= Std.int(e.uData.cost);
			produceNextUnit();
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('producing'));
		}
	}
	private function produceNextUnit(bProducingNext:Bool = false)
	{
		if(actor.data['queue'].length == 1 || bProducingNext)
		{
			var uData = Data.dataMap['units'][actor.data['queue'][0].name];
			kha.Scheduler.addTimeTask(function(){
				var availableNode:Node = null;
				for(n in actor.neighbors)
				{
					if(n.occupant == null)
						availableNode = n;
				}
				var act = new Actor(availableNode, Util.cloneStringMap(uData));
				actor.team.addUnit(act);
				actor.screen.add(act);
				actor.data['queue'].splice(0,1);
				produceNextUnit(actor.data['queue'].length > 0);
			}, actor.data['queue'][0].produceTime/1000, 0, 1);
			trace(actor.data['queue'][0].produceTime);
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle'));
		}
	}
}