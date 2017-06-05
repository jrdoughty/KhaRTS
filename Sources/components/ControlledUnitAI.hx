package components;
import events.TargetEvent;
import events.MoveEvent;
import world.Node;
import systems.AStar;
import actors.Actor;
import events.StopEvent;
import events.ActionEvent;
import haxe.Timer;
import events.HurtEvent;
import events.AnimateAttackEvent;
import events.MoveAnimEvent;
import events.IdleAnimationEvent;
import events.MoveToEvent;
import tween.Delta;
import sdg.event.EventObject;
import components.ActorComponent;
/**
 * ...
 * @author John Doughty
 */
class ControlledUnitAI extends ActorComponent implements AI
{
	public var targetNode(default, null):Node = null;
	public var targetEnemy:Actor = null;

	/**
	 * Nodes that Actor scans for threats
	 */
	public var threatNodes:Array<Node> = [];

	/**
	 * damage dealt when attacking
	 */
	public var damage:Int = 2;
	
	/**
	 * milliseconds between takeAction cycles
	 */
	public var speed:Int = 250;
	
	public var lastState:ActorState;

	/**
	 * timer whose frequency is set by speed
	 */
	private var actionTimer:Timer;

	/**
	 * offset delay timer that starts the action timer. Used to keep AI from starting at the same time. Set to 0 - 1 sec
	 */
	private var delayTimer:Timer;
	
	private var state:ActorState = IDLE;
	private	var path:Array<Node> = [];
	private var failedToMove:Bool = false;
	private var aggressive:Bool = false;
	private var lastTargetNode:Node;
	private var needsReset:Bool = false;
	

	public function new()
	{
		super();
	}
	/**
	 * adds eventlisteners for Move, Atack, and stop
	 */
	override public function init() 
	{
		super.init();
		this.speed = 500;
		this.damage = 1;
		if(!actor.data.exists('threatRange'))
			actor.data.set('threatRange', 4);

		object.eventDispatcher.addEvent(MoveEvent.MOVE, MoveToNode);
		object.eventDispatcher.addEvent(TargetEvent.ATTACK_ACTOR, TargetActor);
		object.eventDispatcher.addEvent(StopEvent.STOP, resetStates);
		//Keeps mass created units from updating at the exact same time. 
		//Idea from: http://answers.unity3d.com/questions/419786/a-pathfinding-multiple-enemies-MOVING-target-effic.html
		delayTimer = new Timer(Math.floor(300*Math.random()));
		delayTimer.run = delayedStart;
	}
	
	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:TargetEvent)
	{
		resetStates();
		targetEnemy = aEvent.target;
	}
	/**
	 * sets node to move to with move sequence, if the event says aggressive, it attacks enemies on the way
	 * if aggressive is off, it will ignore all enemies
	 * @param	moveEvent
	 */
	public function MoveToNode(moveEvent:MoveEvent)
	{
		resetStates();
		targetNode = moveEvent.node;
		aggressive = moveEvent.aggressive;
	}
	
	/**
	 * moves to the next node. If a path doesn't exist to the targetNode, it creates one
	 * It then attepts to move. if blocked a new path will be found
	 */
	private function move():Void
	{
		var nextMove:Node;
		failedToMove = false;
		state = MOVING;
		
		if (aggressive && isEnemyInRange())
		{
			targetEnemy = getEnemyInRange();
			attack();
			return;
		}
		
		if ((targetNode != null && path.length == 0|| targetNode != lastTargetNode) && targetNode.isPassible())
		{
			path = AStar.newPath(actor.currentNodes[0], targetNode);//remember path[0] is the last 
		}
		
		if (path.length > 1 && path[1].occupant == null)
		{
			moveAlongPath();
			
			if (actor.currentNodes[0] == targetNode)
			{
				path = [];
				state = IDLE;//Unlike other cases, this is after the action has been carried out.
			}
		}
		else if (path.length > 1 && path[1].occupant != null)
		{
			newPath();
		}
		else
		{
			targetNode = null;
			state = IDLE;
		}
		lastTargetNode = targetNode;
		if (failedToMove)
		{
			object.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
		else
		{
			object.eventDispatcher.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
		}
	}
	
	/**
	 * for the new path, separated for clean code
	 * if the new path's next position fails to be different, it sets failedToMove to true
	 */
	//@:extern inline 
	private function newPath()
	{
		var nextMove = path[1];
		path = AStar.newPath(actor.currentNodes[0], targetNode);
		if (path.length > 1 && nextMove != path[1])//In Plain english, if the new path is indeed a new path
		{
			//try new path
			if (state == ActorState.MOVING)
			{
				move();	
			} 
			else if (state == ActorState.CHASING)
			{
				chase();
			}
		}
		else
		{
			failedToMove = true;
		}
	}
	
	/**
	 * similar to move function except more complicated, as it needs to determine if the 
	 * targetEnemy has moved and adjust if it has. May merge with Move Eventually
	 */
	private function chase()
	{
		var nextMove:Node;
		var i:Int;
		failedToMove = false;
		
		state = CHASING;
		
		if (targetEnemy != null && targetEnemy.alive)
		{
			
			if (isEnemyInRange())
			{
				attack();
			}
			else
			{
				targetNode = targetEnemy.currentNodes[0];
				
				if (path.length == 0 || path[path.length - 1] != targetNode)
				{
					path = AStar.newPath(actor.currentNodes[0], targetNode);
				}
				
				
				if (path.length > 1 && path[1].occupant == null)
				{
					moveAlongPath();
				}
				else
				{
					newPath();
				}
			}
		}
		else
		{
			state = IDLE;
		}
		if (failedToMove)
		{
			object.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
		else
		{
			object.eventDispatcher.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
		}
	}
	/**
	 * if the enemy is close enough to hit, the attack occurs
	 * if the enemy is too far, the Unit will chase it
	 */
	private function attack()
	{
		var i:Int;
		state = ATTACKING;
		if (targetEnemy != null && targetEnemy.alive)
		{
			if (isEnemyInRange())
			{
				hit();
			}
			else
			{
				chase();
			}
		}
		else
		{
			state = IDLE;
		}
	}
	/**
	 * the neutral state that checks to see if something has happened since the last cycle that didn't change the state
	 * pauses all animations in the neutral position, may need to allow for neutral animations eventually
	 */
	private function idle()
	{
		state = IDLE;
		var i:Int;
		
		object.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		
		if (targetNode != null)
		{
			move();
		}
		else if (targetEnemy != null)
		{
			attack();
		}
		else if (isEnemyInThreat())
		{
			targetEnemy = getEnemyInThreat();
			attack();
		}
	}
	
	/**
	* end of delay timer that starts the takeAction cycle. 
	* This prevents too many AI scripts firing at once
	*/
	private function delayedStart()
    {
	   delayTimer.stop();
	   actionTimer = new Timer(speed);
	   actionTimer.run = takeAction;
    }
	/**
	 * drives actions based on state
	 */
	public function takeAction() 
	{
		lastState = state;
		checkView();
		
		if (needsReset)
		{
			resetStates();
		}
		if (state == IDLE)
		{
			idle();
		}
		else if (state == MOVING)
		{
			move();
		}
		else if (state == ATTACKING)
		{
			attack();
		}
		else if (state == CHASING)
		{
			chase();
		}
	}
	
	/**
	 * damages enemy base on object.damage and targetEnemy.healthMax
	 */
	private function hit()
	{
		targetEnemy.eventDispatcher.dispatchEvent(HurtEvent.HURT, new HurtEvent(damage));
		object.eventDispatcher.dispatchEvent(AnimateAttackEvent.ATTACK, new AnimateAttackEvent());
		if (targetEnemy.alive == false)
		{
			targetEnemy = null;
		}
	}
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetStates(eO:EventObject = null):Void 
	{
		state = IDLE;
		targetEnemy = null;
		aggressive = false;
		targetNode = null;
	}
	
	/**
	 * triggers the tweening of the movement from on node to the next and sets currentNodes and its occupant
	 */
	@:extern inline function moveAlongPath()
	{
		path.splice(0,1)[0].occupant = null;
		actor.currentNodes[0] = path[0];
		actor.currentNodes[0].occupant = actor;

		Delta.tween(object)
			.prop("x",actor.currentNodes[0].x,speed/1000)
			.prop("y",actor.currentNodes[0].y,speed/1000); //Finally report completion;
		//object.x = actor.currentNodes[0].x;
		//object.y = actor.currentNodes[0].y;

		//object.eventDispatcher.addEvent(MoveToEvent.MOVE, new MoveToEvent(actor.currentNodes[0].x,actor.currentNodes[0].y));
	}
	
	/**
	 * checks to see if the enemy is next to the Unit, will need changed for reach
	 * @return whether the enemy is above, below, or to the side
	 */
	private function isEnemyInRange():Bool
	{
		var inRange:Bool = false;
		
		for (i in 0...actor.currentNodes[0].neighbors.length)
		{
			if (actor.currentNodes[0].neighbors[i].occupant == targetEnemy && actor.currentNodes[0].neighbors[i].occupant != null || //if your target is close
			targetEnemy == null && actor.currentNodes[0].neighbors[i].occupant != null && actor.team.isThreat(actor.currentNodes[0].neighbors[i].occupant.team.id)) // if you are near an enemy with no target of your own
			{
				inRange = true;
				break;
			}
		}
		
		return inRange;
	}
	
	/**
	 * checks to see which enemy is next to the Unit, will need changed for reach
	 * @return the enemy that is above, below, or to the side
	 */
	private function getEnemyInRange():Actor
	{
		var result:Actor = null;
		var i:Int;
		for (i in 0...actor.currentNodes[0].neighbors.length)
		{
			if (actor.currentNodes[0].neighbors[i].occupant != null && actor.team.isThreat(actor.currentNodes[0].neighbors[i].occupant.team.id))
			{
				result = actor.currentNodes[0].neighbors[i].occupant;
				break;
			}
		}
		return result;
	}
	
	/**
	 * checks to see if an enemy is in the threat range of the Unit
	 * @return		is an enemy in the threat range
	 */
	private function isEnemyInThreat():Bool
	{
		var i:Int;
		var inRange:Bool = false;
		
		for (i in 0...threatNodes.length)
		{
			if (threatNodes[i].occupant == targetEnemy && threatNodes[i].occupant != null || //if your target is close
			targetEnemy == null && threatNodes[i].occupant != null && actor.team.isThreat(threatNodes[i].occupant.team.id)) // if you are near an enemy with no target of your own
			{
				inRange = true;
				break;
			}
		}
		
		return inRange;
	}
	
	/**
	 * gets first enemy found in threat range
	 * 
	 * @return first enemy found in threat range
	 */
	private function getEnemyInThreat():Actor
	{
		var result:Actor = null;
		var i:Int;
		for (i in 0...threatNodes.length)
		{
			if (threatNodes[i].occupant != null && actor.team.isThreat(threatNodes[i].occupant.team.id))
			{
				result = threatNodes[i].occupant;
				break;
			}
		}
		return result;
	}
	
	/**
	 * Recursively checks neighboring nodes for nodes in threat range
	 * Expensive if threatRange is too great or too many Actors on the field
	 * @param	node 			new Node to check. If not provided, defaults to the currentNode of the Base Actor
	 */
	public function checkView(node:Node = null)
	{
		var n;
		var distance:Float;
		if (node == null)
		{
			node = actor.currentNodes[0];
		}
		for (n in node.neighbors)
		{
			if (threatNodes.indexOf(n) == -1)
			{
				distance = Math.sqrt(Math.pow(Math.abs(actor.currentNodes[0].nodeX - n.nodeX), 2) + Math.pow(Math.abs(actor.currentNodes[0].nodeY - n.nodeY), 2));
				if (distance <= actor.data['threatRange'])
				{
					threatNodes.push(n);
					if (distance < actor.data['threatRange'] && n.isPassible())
					{
						checkView(n);
					}
				}
			}
		}
	}
	/**
	 * detatches component and stops the UnitAI's action Timer
	 */
	public override function destroy() 
	{
		if (actionTimer != null)
		{
			actionTimer.stop();
		}
		super.destroy();
		object.components.remove(this);
	}
}