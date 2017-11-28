package components;
import world.Node;
import events.SimpleEvents;
import sdg.components.Component;
import sdg.event.EventObject;
import actors.Actor;
import events.SimpleEvents;
import sdg.event.EventObject;
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
				actor.data.set('viewRange', 4);
				trace('viewRange not set');
			}
		 	actor.eventDispatcher.addEvent(SimpleEvents.CLEAR, clearNodes);
		 	actor.eventDispatcher.addEvent(SimpleEvents.HIDE, function(e:EventObject){actor.visible = false;});//uproot these when final place is found
		 	actor.eventDispatcher.addEvent(SimpleEvents.REVEAL,  function(e:EventObject){actor.visible = true;});
		}
		else
		{
			destroy();
		}
		
	}
	
	public function clearNodes(e:EventObject = null)
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
					if (distance < actor.data['viewRange'] && n.canSeeOver)
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