package events;
import sdg.event.EventObject;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class KillEvent extends EventObject
{
	public inline static var KILL:String = "KILL";
	public var actor:Actor;
	public function new(a:Actor) 
	{
		actor = a;
		super(true);
		
	}
	
}