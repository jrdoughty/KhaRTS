package components;

import sdg.components.Component;
import actors.Actor;
import events.QueueEvent;
import systems.Data;
import world.Node;

class Building extends Component
{
	private var actor:Actor;

	public override function init()
	{
		super.init();
		if(Type.getClass(object) == Actor)
			actor = cast(object, Actor);
		else
		{
			destroy();
			return;
		}
		actor.data['queue'] = new Array<UnitData>();
		actor.eventDispatcher.addEvent(QueueEvent.QUEUE, QueueUnitAction);
	}

	private function QueueUnitAction(e:QueueEvent)
	{
		actor.data['queue'].push(e.uData);
		if(e.uData.cost <= actor.team.resources)
		{
			actor.team.resources -= Std.int(e.uData.cost);
			produceNextUnit();
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
			}, actor.data['queue'][0].coolDown/1000, 0, 1);
			trace(actor.data['queue'][0].coolDown);
		}
	}
}