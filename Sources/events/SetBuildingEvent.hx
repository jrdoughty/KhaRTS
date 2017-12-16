package events;
import sdg.event.EventObject;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class SetBuildingEvent extends EventObject
{
	public var target:Actor;
	public static inline var BUILD_ACTOR:String = "BUILD_ACTOR";
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