package actors;

import sdg.Object;
import sdg.components.Component;
import sdg.graphics.Sprite;
import sdg.atlas.Region;
import world.Node;
import kha.Image;
import kha.Assets;
import sdg.atlas.Atlas;
import systems.Team;
import sdg.components.EventDispatcher;
import components.StateAI;
import components.Health;
import components.BasicAnimator;
import components.View;
import components.ComponentSystem;
/**
 * @author John Doughty
 */

class Actor extends Object
{
	/**
	 * Nodes Taken up by Actor
	 */
	public var currentNodes:Array<Node> = [];

	/**
	 * Team Actor belongs to
	 */
	public var team:Team = null;
	
	public var alive:Bool = true;
	/**
	 * selected state bool
	 */
	public var selected:Bool = false;

	/**
	* data storage for sharing information between components and actors
	*/
	public var data:Map<String, Dynamic>;

	public function new(node:Node,  data:Map<String, Dynamic>)
	{
		super();
		x = node.x;
		y = node.y;
		addComponent(new EventDispatcher());
		var image:Image = Reflect.field(Assets.images, data['image']);
		var rl:Array<Region> = Atlas.createRegionList(image, data['width'], data['height']);
		data.set('rl', rl);
		graphic = new Sprite(rl[0]);
		setSizeAuto();
		setupNodes(node);
		var compData:Array<Dynamic> = data['comps'];
		for(i in compData)
		{
			addComponent(ComponentSystem.getInstance().getC(i.name));
		}
		this.data = data;
	}
	
	/**
	 * sets all the nodes it graphically covers (and the provided node) to be occupied by this Actor
	 * Needs refactored so that it uses node width
	 * 
	 * @param	node				the top left most Node the Actor takes up
	 */
	private function setupNodes(node:Node)
	{
		currentNodes = node.getAllNodes(Std.int(width / node.width) - 1, Std.int(height / node.height) - 1);
		
		for (i in 0...currentNodes.length)
		{
			currentNodes[i].occupant = this;
		}
	}	
	/**
	 * ensures the Actor's actions are removed and that the Actor is no longer on the field
	 * also detatches components
	 */
	public function kill()
	{
		alive = false;
		team.units.remove(this);
		for(i in currentNodes)
		{
			i.occupant = null;
		}
	}
}