package states;
import actors.Actor;
import events.StateChangeEvent;
import events.AnimateAttackEvent;
import events.HurtEvent;
import events.MoveAnimEvent;
import events.IdleAnimationEvent;
import world.Node;
import systems.AStar;
import tween.Delta;
import events.StopEvent;
import events.TargetEvent;

class AttackState extends BaseState
{
	private var path:Array<Node> = [];
	private var failedToMove:Bool = false;

	public function new(a:Actor)
	{
		super(a);
		
		if(a.data['damage'])
			a.eventDispatcher.addEvent(TargetEvent.ATTACK_ACTOR, TargetActor);
		else
			trace('attacking unit created without damage value');
		a.eventDispatcher.addEvent(StopEvent.STOP, resetData);
	}

	public override function takeAction()
	{
		var i:Int;
		
		if (actor.data['targetEnemy'] != null && actor.data['targetEnemy'].alive)
		{
			if (isEnemyInRange())
			{
				hit();
			}
			else if(actor.data['mobile'])
			{
				chase();
			}
		}
		else
		{
			if(actor.data['targetEnemy'] != null && !actor.data['targetEnemy'].alive)
				actor.data['targetEnemy'] = null;
			
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}
		
	/**
	 * damages enemy base on object.damage and targetEnemy.healthMax
	 */
	private function hit()
	{
		actor.data['targetEnemy'].eventDispatcher.dispatchEvent(HurtEvent.HURT, new HurtEvent(actor.data['damage']));
		actor.eventDispatcher.dispatchEvent(AnimateAttackEvent.ATTACK, new AnimateAttackEvent());
		if (actor.data['targetEnemy'].alive == false)
		{
			actor.data['targetEnemy'] = null;
		}
	}

	/**
	 * similar to move function except more complicated, as it needs to determine if the 
	 * targetEnemy has moved and adjust if it has. May merge with Move Eventually
	 */
	private function chase()
	{
		failedToMove = false;
		
		
		if (path.length == 0 || path[path.length - 1] != actor.data['targetEnemy'].currentNodes[0])
		{
			path = AStar.newPath(actor.currentNodes[0], actor.data['targetEnemy'].currentNodes[0]);
		}
		
		
		if (path.length > 1 && path[1].occupant == null)
		{
			moveAlongPath();
		}
		else
		{
			newPath();
		}
		if (failedToMove)
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
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
		path = AStar.newPath(actor.currentNodes[0], actor.data['targetEnemy'].currentNodes[0]);
		if (path.length > 1 && nextMove != path[1])//In Plain english, if the new path is indeed a new path
		{
			chase();
		}
		else
		{
			failedToMove = true;
		}
	}
	
	/**
	 * triggers the tweening of the movement from on node to the next and sets currentNodes and its occupant
	 */
	@:extern inline function moveAlongPath()
	{
		path.splice(0,1)[0].occupant = null;
		actor.currentNodes[0] = path[0];
		actor.currentNodes[0].occupant = actor;

		Delta.tween(actor)
			.prop("x",actor.currentNodes[0].x,actor.data['speed']/1000)
			.prop("y",actor.currentNodes[0].y,actor.data['speed']/1000); //Finally report completion;
	}
	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:TargetEvent)
	{
		actor.eventDispatcher.dispatchEvent(StopEvent.STOP, new StopEvent());
		actor.data['targetEnemy'] = aEvent.target;
	}
	
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:StopEvent = null):Void 
	{
		actor.data.set('targetEnemy', null);
		actor.data.set('aggressive', false);
	}
}