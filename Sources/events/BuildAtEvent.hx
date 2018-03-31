package events;

import sdg.event.EventObject;
import world.Node;

class BuildAtEvent extends EventObject
{
	public static var BUILD:String = 'BUILD';
	public var node:Node;
	public var bData:Map<String,Dynamic>;
	public function new(tNode:Node, bData:Map<String,Dynamic>)
	{
		this.node = tNode;
		this.bData = bData;
		super(false);
	}
}