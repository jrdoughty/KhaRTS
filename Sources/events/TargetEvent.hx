package events;
import sdg.event.EventObject;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class TargetEvent extends EventObject
{
	public var target:Actor;
	public static inline var ATTACK_ACTOR:String = "ATTACK_ACTOR";
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