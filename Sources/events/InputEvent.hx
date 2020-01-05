package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class InputEvent extends EventObject 
{
	public static inline var STOP:String = "STOP_INPUT";
	public static inline var MOVE:String = "MOVE_INPUT";
	public static inline var ATTACK:String = "ATTACK_INPUT";

    public function new() 
    {
		super(true);        
    }
}