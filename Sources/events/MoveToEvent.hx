package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class MoveToEvent extends EventObject
{
	public static inline var MOVE:String = "MOVE_TO";
	
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float, y:Float) 
	{
		super();
		
		this.x = x;
		this.y = y;
	}
	
}