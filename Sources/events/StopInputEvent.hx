package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class StopInputEvent extends EventObject
{

	public static inline var STOP:String = "STOP_INPUT";
	public function new() 
	{
		super(true);
	}
}