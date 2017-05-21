package states;

import events.IdleAnimationEvent;

class IdleState extends BaseState
{

	public override function takeAction()
	{
		var i:Int;
		
		actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		
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
	 * checks to see if the enemy is next to the Unit, will need changed for reach
	 * @return whether the enemy is above, below, or to the side
	 */
	private function isEnemyInRange():Bool
	{
		var inRange:Bool = false;
		
		for (i in 0...actor.currentNodes[0].neighbors.length)
		{
			if (actor.currentNodes[0].neighbors[i].occupant == argetEnemy && actor.currentNodes[0].neighbors[i].occupant != null || //if your target is close
			targetEnemy == null && actor.currentNodes[0].neighbors[i].occupant != null && actor.team.isThreat(actor.currentNodes[0].neighbors[i].occupant.team.id)) // if you are near an enemy with no target of your own
			{
				inRange = true;
				break;
			}
		}
		
		return inRange;
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
	
}