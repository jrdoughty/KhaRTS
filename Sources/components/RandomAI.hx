package components;

import events.MoveAnimEvent;
import events.IdleAnimationEvent;
/**
 * ...
 * @author John Doughty
 */
class RandomAI extends ControlledUnitAI
{
	/**
	 * the neutral state that checks to see if something has happened since the last cycle that didn't change the state
	 * pauses all animations in the neutral position, may need to allow for neutral animations eventually
	 */
	override private function idle()
	{
		state = IDLE;
		var i:Int;
		var indexOffset:Int = 1;
		
		entity.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		
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
		else
		{
			if (Math.random() < .2)
			{		
				indexOffset *= Math.floor(Math.random() * 4);
				for (i in 0...entity.currentNodes[0].neighbors.length)
				{
					var index = (i + indexOffset) % entity.currentNodes[0].neighbors.length;
					if (entity.currentNodes[0].neighbors[index].isPassible())
					{
						targetNode = entity.currentNodes[0].neighbors[index];
						entity.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
						break;
					}
				}
			}
		}
	}
	
}