package events;
import world.Node;
import sdg.event.EventObject;

/**
 * ...
 * @author John Doughty
 */
class MoveEvent extends EventObject
{
	public var node:Node;
	public var aggressive:Bool;
	public static inline var MOVE:String = "MOVE";
	
	/**
	 * 
	 * @param	node		Node to be moved toward
	 * @param	aggressive	whether or not attack enemies along the way
	 */
	public function new(node:Node, aggressive:Bool = false) 
	{
		this.node = node;
		this.aggressive = aggressive;
		super();
		
	}
	
}