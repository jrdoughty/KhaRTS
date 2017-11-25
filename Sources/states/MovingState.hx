package states;
import actors.Actor;
import events.StateChangeEvent;
import events.AnimateEvent;
import world.Node;
import systems.AStar;
import tween.Delta;
import events.ChangeTimingEvent;
class MovingState extends BaseState
{
	private var path:Array<Node> = [];
	private var failedToMove:Bool = false;
	private var diag:Bool = false;

	public function new(a:Actor)
	{
		super(a);
	}

	/**
	 * moves to the next node. If a path doesn't exist to the targetNode, it creates one
	 * It then attepts to move. if blocked a new path will be found
	 */
	public override function takeAction():Void
	{
		failedToMove = false;
		if(diag == true)
			actor.eventDispatcher.dispatchEvent(events.ChangeTimingEvent.CHANGE, new events.ChangeTimingEvent(actor.data['moveCoolDown']*1));
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
		}
	}
	
	/**
	 * triggers the tweening of the movement from on node to the next and sets currentNodes and its occupant
	 */
	//@:extern inline 
	function moveAlongPath()
	{
		diag = path[0].x != path[1].x && path[0].y != path[1].y;
		path.splice(0,1)[0].occupant = null;
		actor.currentNodes[0] = path[0];
		actor.currentNodes[0].occupant = actor;
		if(diag)
		{
			actor.coolDown = Math.round(actor.data['moveCoolDown'] * 1.4);
			Delta.tween(actor)
				.prop("x",actor.currentNodes[0].x, actor.data['moveCoolDown'] * 1.4 / 1000)
				.prop("y",actor.currentNodes[0].y, actor.data['moveCoolDown'] * 1.4 / 1000);
		}
		else
		{
			actor.coolDown = Math.round(actor.data['moveCoolDown']);
			Delta.tween(actor)
				.prop("x",actor.currentNodes[0].x, actor.data['moveCoolDown'] / 1000)
				.prop("y",actor.currentNodes[0].y, actor.data['moveCoolDown'] / 1000);
		}
	}

	function animateMove()
	{
		if (failedToMove)
		{
			actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('idle', true));
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(AnimateEvent.ANIMATE, new AnimateEvent('move', true));
		}
	}
}