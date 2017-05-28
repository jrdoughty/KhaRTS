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
	public var type:String;
	public function new(dmg:Int, type:String = 'normal') 
	{
		super();
		damage = dmg;
		this.type = type;
	}
	
}