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



class StateAI extends ActorComponent implements AI
{
	var states :Map<String, IState> = new  Map<String, IState>();
	var actionTimer: Int;

	public function new ()
	{
		super();
	}
	public override function init()
	{
		super.init();
		//object.eventDispatcher.a
		var ai;
		if(actor.data != null)
			ai = actor.data.ai;
		else if(actor.buildingData != null)
			ai = actor.buildingData.ai;
		else 
		{
			trace("looking for AI for non-building/unit");
			return;
		}

		object.eventDispatcher.addEvent(SimpleEvents.STOP, resetStates);
		object.eventDispatcher.addEvent(StateChangeEvent.CHANGE, changeState);
		for(i in ai.states)
		{
			var key:String = 'idle';
			var rf = i.name;
			var name:String = cast (rf.name, String);
			if(name.indexOf('main') == -1)
				key = name;
			states.set(key, StateFactory.create(name, actor));
		}
		if(actor.currentState == null)//should only happen from being loaded in
		{
			actor.currentState = 'idle';
			states[actor.currentState].enter();
		}
		//Keeps mass created units from updating at the exact same time. 
		//Idea from: http://answers.unity3d.com/questions/419786/a-pathfinding-multiple-enemies-MOVING-target-effic.html

		actionTimer = Sdg.addTimeTask(delayedStart, .2 * Math.random());
	}
	/**
	* end of delay timer that starts the takeAction cycle. 
	* This prevents too many AI scripts firing at once
	*/
	private function delayedStart()
	{
		Sdg.removeTimeTask(actionTimer);
		actionTimer = Sdg.addTimeTask(takeAction, actor.coolDown/1000,0,1);
	}
	/**
	 * drives actions based on state
	 */
	public function takeAction() 
	{
		if(actor.nextState != null)
		{
			if(actor.currentState != null)
				states[actor.currentState].exit();
			actor.currentState = actor.nextState;
			actor.nextState = null;
			states[actor.currentState].enter();
		}
		actor.lastState = actor.currentState;
		states[actor.currentState].takeAction();
		actionTimer = Sdg.addTimeTask(takeAction, actor.coolDown/1000,0,1);
	}
	
	/**
	 * resets state to idle
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetStates(eO:EventObject = null):Void 
	{
		actor.nextState = 'idle';
	}

	private function changeState(e:StateChangeEvent)
	{
		if(states.exists(e.state) && e.state != actor.currentState)
		{
			states[actor.currentState].exit();
			if(e.immediate)
			{
				actor.currentState = e.state;
				states[actor.currentState].takeAction();
			}
			else
			{
				actor.nextState = e.state;
			}
			states[e.state].enter();
		}
	}
	/**
	 * detatches component and stops the UnitAI's action Timer
	 */
	public override function destroy() 
	{
		Sdg.removeTimeTask(actionTimer);
		actor.components.remove(this);
		super.destroy();
	}
}