package states;

import world.Node;
import actors.Actor;

class BaseState implements IState
{

	public function enter()
	{

	}

	public function exit()
	{
		
	}
	private var actor:Actor;

	/**
	 * Nodes that Actor scans for threats
	 */
	public var threatNodes:Array<Node> = [];

	public function new(a:Actor)
	{
		actor = a;
	}

	public function takeAction()
	{

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
			if (threatNodes[i].occupant == actor.data['targetEnemy'] && threatNodes[i].occupant != null || //if your target is close
			actor.data['targetEnemy'] == null && threatNodes[i].occupant != null && actor.team.isThreat(threatNodes[i].occupant.team.id) && threatNodes[i].occupant.data.exists('health')) // if you are near an enemy with no target of your own
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
		for (i in 0...threatNodes.length)
		{
			if (threatNodes[i].occupant != null && actor.team.isThreat(threatNodes[i].occupant.team.id) && threatNodes[i].occupant.data.exists('health'))
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
	
}