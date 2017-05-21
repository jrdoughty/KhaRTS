package states;


class AttackState extends BaseState
{

	public override function takeAction()
	{
		var i:Int;
		
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
				hit();
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
	
}