package events;

import sdg.event.EventObject;
import world.Node;
import systems.Data.Buildings;

class BuildAtEvent extends EventObject
{
	public static var BUILD:String = 'BUILD';
	public var node:Node;
	public function new(tNode:Node)
	{
		this.node = tNode;
		super(false);
	}
}