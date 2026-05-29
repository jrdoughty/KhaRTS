package events;

import sdg.event.EventObject;
import world.Node;
import systems.Data.Buildings;

class BuildAtEvent extends EventObject
{
	public static var BUILD:String = 'BUILD';
	public var node:Node;
	public var bData:Buildings;
	public function new(tNode:Node, bData:Buildings)
	{
		this.node = tNode;
		this.bData = bData;
		super(false);
	}
}