package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class HurtEvent extends EventObject
{
	public var damage:Int;
	public inline static var HURT:String = "HURT";
	public function new(dmg:Int) 
	{
		super();
		damage = dmg;
	}
	
}