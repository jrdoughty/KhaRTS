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

typedef ViewData = {/**
	* Nodes scanned to clear fog of war
	*/
   public var clearedNodes:Array<Node>;

   /**
   * pointer to help prevent unnecessary casting
   */
   public var actor:Actor;
}

class View extends Component
{
	var data:ViewData = {
		clearedNodes: [],
		actor: null
	}	
	public function new() 
	{
		super();
	}
	
	override public function init() 
	{
		super.init();
		
		if (Type.getClass(object) == Actor)
		{
			data.actor = cast object;
			if(!data.actor.data.exists('viewRange'))
			{
				data.actor.data.set('viewRange', 4);
				trace('viewRange not set');
			}
			data.actor.eventDispatcher.addEvent(SimpleEvents.CLEAR, clearNodes);
			data.actor.eventDispatcher.addEvent(SimpleEvents.HIDE, function(e:EventObject){data.actor.visible = false;});//uproot these when final place is found
			data.actor.eventDispatcher.addEvent(SimpleEvents.REVEAL,  function(e:EventObject){data.actor.visible = true;});
		}
		else
		{
			destroy();
		}
		
	}
	
	public function clearNodes(e:EventObject = null)
	{
		data.clearedNodes = [];
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
			node = data.actor.currentNodes[0];
		}
		for (n in node.neighbors)
		{
			if (data.clearedNodes.indexOf(n) == -1)
			{
				distance = Math.sqrt(Math.pow(Math.abs(data.actor.currentNodes[0].nodeX - n.nodeX), 2) + Math.pow(Math.abs(data.actor.currentNodes[0].nodeY - n.nodeY), 2));
				if (distance <= data.actor.data['viewRange'])
				{
					n.removeOverlay();
					data.clearedNodes.push(n);
					if (distance < data.actor.data['viewRange'] && n.canSeeOver)
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