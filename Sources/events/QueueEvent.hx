package events;
import sdg.event.EventObject;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */

typedef UnitData = {
	var name : String;
	var cost : Int;
	var coolDown : Int; 
}
class QueueEvent extends EventObject
{
	public var uData:UnitData;
	public static inline var QUEUE:String = "QUEUE";

	/**
	 * 
	 * @param	target		Actor to be attacked
	 */
	public function new(uData:UnitData) 
	{
		super();
		this.uData = uData;
	}
	
}