package events;
import sdg.event.EventObject;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class GatherEvent extends EventObject
{
	public var target:Actor;
	public static inline var GATHER:String = "GATHER";
	/**
	 * 
	 * @param	target		Actor to be attacked
	 */
	public function new(target:Actor) 
	{
		super();
		this.target = target;
	}
	
}