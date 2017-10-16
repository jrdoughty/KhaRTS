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

class AttackState extends MovingState
{

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
		super.takeAction();
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
		var ed = actor.data['targetEnemy'].eventDispatcher;//hack to deal with js error, js gets confusted as to what 'this' should be
		ed.dispatchEvent(HurtEvent.HURT, new HurtEvent(actor.data['damage']));
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