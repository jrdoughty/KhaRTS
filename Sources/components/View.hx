package components;
import world.Node;
import events.ClearFogEvent;
/**
 * ...
 * @author John Doughty
 */
class View extends Component
{


	/**
	 * How many nodes over can the BaseActor's view clear the Fog of War
	 */
	public var viewRange:Int = 2;

	/**
	 * Nodes scanned to clear fog of war
	 */
	public var clearedNodes:Array<Node> = [];
	
	
	public function new(name:String) 
	{
		super(name);
	}
	
	override public function init() 
	{
		super.init();
		
		if (Reflect.hasField(entity.eData, "viewRange"))
		{
			this.viewRange = entity.eData.viewRange;
		}
		else
		{
			entity.removeC(name);
		}
		
		entity.addEvent(ClearFogEvent.CLEAR, clearNodes);
	}
	
	public function clearNodes(e:ClearFogEvent = null)
	{
		clearedNodes = [];
		clearFogOfWar();
	}
	
	/**
	 * used to clear fog of war if the BaseActor has a viewRange
	 * recursive function, expensive if viewRange is made too large or too many BaseActors are on Active Team
	 * 
	 * @param	node			new Node to check. If not provided, defaults to the currentNode of the Base Actor
	 */
	public function clearFogOfWar(node:Node = null)
	{
		var n;
		var distance:Float;
		if (node == null)
		{
			node = entity.currentNodes[0];
		}
		for (n in node.neighbors)
		{
			if (clearedNodes.indexOf(n) == -1)
			{
				distance = Math.sqrt(Math.pow(Math.abs(entity.currentNodes[0].nodeX - n.nodeX), 2) + Math.pow(Math.abs(entity.currentNodes[0].nodeY - n.nodeY), 2));
				if (distance <= viewRange)
				{
					n.removeOverlay();
					clearedNodes.push(n);
					if (distance < viewRange && n.isPassible())
					{
						clearFogOfWar(n);
					}
				}
			}
		}
	}
}