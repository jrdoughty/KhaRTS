package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class ChangeTimingEvent extends EventObject
{
	public var milSec:Int;
	public inline static var CHANGE:String = "CHANGE";
	public function new(milSec:Int) 
	{
		super();
		this.milSec = milSec;
	}
	
}