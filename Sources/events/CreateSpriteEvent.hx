package events;
import sdg.event.EventObject;
import world.Node;

import actors.Animation;
/**
 * ...
 * @author ...
 */
class CreateSpriteEvent extends EventObject
{
	public var node:Node;
	//public var idleFrame:Int;
	//public var animations:Array<Animation>;
	public var data:Dynamic;
	public static inline var CREATE_SPRITE:String = "CREATE_SPRITE";
	
	public function new() 
	{
		super();
		
	}
	
}