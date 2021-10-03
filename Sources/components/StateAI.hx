package components;

import actors.Actor;
import states.IState;
import events.TargetEvent;
import events.MoveEvent;
import events.SimpleEvents;
import events.StateChangeEvent;
import sdg.event.EventObject;
import components.ActorComponent;
import states.StateFactory;
import systems.Data;
import haxe.Timer;
import sdg.Sdg;
import events.ChangeTimingEvent;


typedef StateAIData = {
	public var states:Map<String, IState>;
	public var state:IState;
	public var nextState:String;
	public var currentState:String;
	public var lastState:String;
	public var actionTimer:Int;
}

class StateAI extends ActorComponent implements AI
{
	var data = {
		states : new  Map<String, IState>(),
		nextState : null,
		currentState : null,
		lastState : null,
		actionTimer: null
	};

	public function new ()
	{
		super();
	}
	public override function init()
	{
		super.init();

		object.eventDispatcher.addEvent(SimpleEvents.STOP, resetStates);
		object.eventDispatcher.addEvent(StateChangeEvent.CHANGE, changeState);
		//object.eventDispatcher.addEvent(ChangeTimingEvent.CHANGE, newActionTime);

		var ais:Array<Dynamic> = cast (Data.dataMap['ai'][actor.data['ai']]['states'], Array<Dynamic>);
		for(i in ais)
		{
			var key:String = 'idle';
			if(i.name.indexOf('main') == -1)
				key = i.name;
			data.states.set(key, StateFactory.create(i.name, actor));
		}
		data.currentState = 'idle';
		data.states[data.currentState].enter();
		//Keeps mass created units from updating at the exact same time. 
		//Idea from: http://answers.unity3d.com/questions/419786/a-pathfinding-multiple-enemies-MOVING-target-effic.html

		data.actionTimer = Sdg.addTimeTask(delayedStart, .2 * Math.random());
	}
	/**
	* end of delay timer that starts the takeAction cycle. 
	* This prevents too many AI scripts firing at once
	*/
	private function delayedStart()
	{
		Sdg.removeTimeTask(data.actionTimer);
		data.actionTimer = Sdg.addTimeTask(takeAction, actor.coolDown/1000,0,1);
	}
	/**
	 * drives actions based on state
	 */
	public function takeAction() 
	{
		if(data.nextState != null)
		{
			if(data.currentState != null)
				data.states[data.currentState].exit();
			data.currentState = data.nextState;
			data.nextState = null;
			data.states[data.currentState].enter();
		}
		data.lastState = data.currentState;
		data.states[data.currentState].takeAction();
		data.actionTimer = Sdg.addTimeTask(takeAction, actor.coolDown/1000,0,1);
	}
	
	/**
	 * resets state to idle
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetStates(eO:EventObject = null):Void 
	{
		data.nextState = 'idle';
	}

	private function changeState(e:StateChangeEvent)
	{
		if(data.states.exists(e.state) && e.state != data.currentState)
		{
			data.states[data.currentState].exit();
			if(e.immediate)
			{
				data.currentState = e.state;
				data.states[data.currentState].takeAction();
			}
			else
			{
				data.nextState = e.state;
			}
			data.states[e.state].enter();
		}
	}
	/**
	 * detatches component and stops the UnitAI's action Timer
	 */
	public override function destroy() 
	{
		Sdg.removeTimeTask(data.actionTimer);
		super.destroy();
		object.components.remove(this);
	}
}