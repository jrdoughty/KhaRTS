package states;
import actors.Actor;
import events.StateChangeEvent;
import events.MoveAnimEvent;
import events.IdleAnimationEvent;
import world.Node;
import systems.AStar;
import tween.Delta;

class MoveState extends BaseState
{
	private var path:Array<Node> = [];
	private var failedToMove:Bool = false;
	private var lastTargetNode:Node;
	private var turnsIdle:Int = 0;

	/**
	 * moves to the next node. If a path doesn't exist to the targetNode, it creates one
	 * It then attepts to move. if blocked a new path will be found
	 */
	public override function takeAction():Void
	{
		failedToMove = false;
		if (actor.data['aggressive'])
		{
			checkView();
			actor.data['targetEnemy'] = getEnemyInThreat();	
			if(actor.data['targetEnemy'] != null)
			{
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(ATTACKING));
				return;
			}
		}
		
		if ((actor.data['targetNode'] != null && path.length == 0|| actor.data['targetNode'] != lastTargetNode) && actor.data['targetNode'].isPassible())
		{
			path = AStar.newPath(actor.currentNodes[0], actor.data['targetNode']);//remember path[0] is the last 
		}
		
		if (path.length > 1 && path[1].occupant == null)
		{
			moveAlongPath();
			turnsIdle = 0;
			if (actor.currentNodes[0] == actor.data['targetNode'])
			{
				path = [];
				actor.data['targetNode'] = null;
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(IDLE));//Unlike other cases, this is after the action has been carried out.
			}
		}
		else if (path.length > 1 && path[1].occupant != null)
		{
			newPath();
			trace('test');
		}
		else
		{
			turnsIdle++;
			if(turnsIdle > 3)
			{
				actor.data['targetNode'] = null;
				actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent(IDLE));
			}
		}
		lastTargetNode = actor.data['targetNode'];
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
		path = AStar.newPath(actor.currentNodes[0], actor.data['targetNode']);
		if (path.length > 1 && nextMove != path[1])//In Plain english, if the new path is indeed a new path
		{
			takeAction();//try again
		}
		else
		{
			failedToMove = true;
			trace('fail');
		}
	}
	
	/**
	 * triggers the tweening of the movement from on node to the next and sets currentNodes and its occupant
	 */
	//@:extern inline 
	function moveAlongPath()
	{
		path.splice(0,1)[0].occupant = null;
		actor.currentNodes[0] = path[0];
		actor.currentNodes[0].occupant = actor;

		Delta.tween(actor)
			.prop("x",actor.currentNodes[0].x,actor.data['speed']/1000)
			.prop("y",actor.currentNodes[0].y,actor.data['speed']/1000); //Finally report completion;
	}
}