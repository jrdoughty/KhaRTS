package components;
import world.Node;
import events.ClearFogEvent;
import sdg.components.Component;
import actors.Actor;
/**
 * ...
 * @author John Doughty
 */
class View extends Component
{
	/**
	 * Nodes scanned to clear fog of war
	 */
	public var clearedNodes:Array<Node> = [];

	/**
	* pointer to help prevent unnecessary casting
	*/
	private var actor:Actor;
	
	
	public function new() 
	{
		super();
	}
	
	override public function init() 
	{
		super.init();
		
		if (Type.getClass(object) == Actor)
		{
			actor = cast object;
			if(!actor.data.exists('viewRange'))
			{
				actor.data.set('viewRange', 2);
			}
		 	actor.eventDispatcher.addEvent(ClearFogEvent.CLEAR, clearNodes);
		}
		else
		{
			destroy();
		}
		
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
			node = actor.currentNodes[0];
		}
		for (n in node.neighbors)
		{
			if (clearedNodes.indexOf(n) == -1)
			{
				distance = Math.sqrt(Math.pow(Math.abs(actor.currentNodes[0].nodeX - n.nodeX), 2) + Math.pow(Math.abs(actor.currentNodes[0].nodeY - n.nodeY), 2));
				if (distance <= actor.data['viewRange'])
				{
					n.removeOverlay();
					clearedNodes.push(n);
					if (distance < actor.data['viewRange'] && n.isPassible())
					{
						clearFogOfWar(n);
					}
				}
			}
		}
	}

	public override function destroy()
	{
		object.components.remove(this);
	}
}