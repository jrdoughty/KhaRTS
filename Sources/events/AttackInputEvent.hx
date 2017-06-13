package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class AttackInputEvent extends EventObject
{

	public static inline var ATTACK:String = "ATTACK_INPUT";
	public function new() 
	{
		super(true);
	}
}