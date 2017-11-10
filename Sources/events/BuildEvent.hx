package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class BuildEvent extends EventObject
{

	public static inline var BUILD:String = "BUILD";
	public function new() 
	{
		super();
	}
}