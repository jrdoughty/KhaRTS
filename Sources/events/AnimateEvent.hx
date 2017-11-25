package events;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class AnimateEvent extends EventObject
{
	public var anim:String;
	public var loop:Bool;
	public static inline var ANIMATE:String = "ANIMATE";
	public function new(anim:String = 'idle', loop:Bool = true) 
	{
		this.anim = anim;
		this.loop = loop;
		super();
	}
	
}