package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class MoveInputEvent extends EventObject
{

	public static inline var MOVE:String = "MOVE_INPUT";
	public function new() 
	{
		super(true);
	}
}