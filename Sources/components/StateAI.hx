package components;

import actors.Actor;
import states.IState;
import states.IdleState;
import events.TargetEvent;
import events.MoveEvent;
import events.StopEvent;
import events.StateChangeEvent;
import sdg.event.EventObject;

import haxe.Timer;

class StateAI extends AI
{
	var states:Map<ActorState, IState> = new Map<ActorState, IState>();
	var state:IState;
	var nextState:ActorState;
	var currentState:ActorState;
	var lastState:ActorState = null;
	/**
	 * timer whose frequency is set by speed
	 */
	private var actionTimer:Timer;

	/**
	 * offset delay timer that starts the action timer. Used to keep AI from starting at the same time. Set to 0 - 1 sec
	 */
	private var delayTimer:Timer;

	public function new ()
	{
		super();
	}
	public override function init()
	{
		super.init();
		actor.data.set('speed', 500);
		actor.data.set('targetEnemy', null);
		actor.data.set('targetNode', null);
		actor.data.set('aggressive', false);
		object.eventDispatcher.addEvent(MoveEvent.MOVE, MoveToNode);
		object.eventDispatcher.addEvent(TargetEvent.ATTACK_ACTOR, TargetActor);
		object.eventDispatcher.addEvent(StopEvent.STOP, resetStates);
		object.eventDispatcher.addEvent(StateChangeEvent.CHANGE, changeState);
		
		states.set(IDLE, new IdleState(actor));
		state = states.get(IDLE);
		//Keeps mass created units from updating at the exact same time. 
		//Idea from: http://answers.unity3d.com/questions/419786/a-pathfinding-multiple-enemies-MOVING-target-effic.html
		delayTimer = new Timer(Math.floor(300*Math.random()));
		delayTimer.run = delayedStart;
	}
	/**
	* end of delay timer that starts the takeAction cycle. 
	* This prevents too many AI scripts firing at once
	*/
	private function delayedStart()
    {
	   delayTimer.stop();
	   actionTimer = new Timer(actor.data['speed']);
	   actionTimer.run = takeAction;
    }
	/**
	 * drives actions based on state
	 */
	override function takeAction() 
	{
		if(nextState != null)
		{
			currentState = nextState;
			nextState = null;
		}
		super.takeAction();
		lastState = currentState;
		state.takeAction();
	}
	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:TargetEvent)
	{
		resetStates();
		actor.data['targetEnemy'] = aEvent.target;
	}
	/**
	 * sets node to move to with move sequence, if the event says aggressive, it attacks enemies on the way
	 * if aggressive is off, it will ignore all enemies
	 * @param	moveEvent
	 */
	public function MoveToNode(moveEvent:MoveEvent)
	{
		resetStates();
		actor.data['targetNode'] = moveEvent.node;
		actor.data['aggressive'] = moveEvent.aggressive;
	}
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetStates(eO:EventObject = null):Void 
	{
		actor.data.set('targetEnemy', null);
		actor.data.set('targetNode', null);
		actor.data.set('aggressive', false);
		nextState = IDLE;
	}

	private function changeState(e:StateChangeEvent)
	{
		
		if(e.immediate)
		{
			currentState = e.state;
			states[currentState].takeAction();
		}
		else
		{
			nextState = e.state;
		}
	}
}