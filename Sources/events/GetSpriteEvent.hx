package events;
import sdg.event.EventObject;
import haxe.Constraints.Function;

/**
 * ...
 * @author John Doughty
 */
class GetSpriteEvent extends EventObject
{
	public static var GET:String = "GET";
	public var callBackFunction:Function;
	public function new(cf:Function) 
	{
		super();
		
		callBackFunction = cf;
	}
	
}