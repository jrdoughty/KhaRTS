package actors;

import events.QueueEvent.UnitData;
import sdg.Object;
import sdg.graphics.Sprite;
import sdg.atlas.Region;
import world.Node;
import kha.Image;
import kha.Assets;
import sdg.atlas.Atlas;
import systems.Team;
import systems.Data.Units;
import systems.Data.Buildings;
import systems.Data.Resources;
import sdg.components.EventDispatcher;
import components.ComponentSystem;
import sdg.pathfinding.INode;
import sdg.ds.ThreeOptions;
/**
 * @author John Doughty
 */

abstract DataType(ThreeOptions<Units,Buildings,Resources>)
{
	@:dox(hide) public inline function new(e:ThreeOptions<Units,Buildings,Resources>) this = e;
	@:dox(hide) public var type(get, never):ThreeOptions<Units,Buildings,Resources>;
	@:to inline function get_type() return this;
	@:from static function fromFirst(v:Units) return new DataType(First(v));
	@:from static function fromSecond(v:Buildings) return new DataType(Second(v));
	@:from static function fromThird(v:Resources) return new DataType(Third(v));
}
class Actor extends Object
{
	/**
	 * Nodes Taken up by Actor
	 */
	public var currentNodes:Array<Node> = [];

	/**
	 * Nodes surrounding actor
	 */
	public var neighbors:Array<Node> = [];

	/**
	 *
	**/
	public var targetNode:INode;

	/**
	 *
	**/
	public var targetEnemy:Actor;

	/**
	 *
	**/
	public var targetBuilding:Actor;

	/**
	 * Team Actor belongs to
	 */
	public var team:Team = null;
	
	public var alive:Bool = true;
	public var health:Float = 1;
	public var healthMax:Int = 1;
	public var aggressive:Bool = false;
	/**
	 * selected state bool
	 */
	public var selected:Bool = false;

	/**
	* cool down time between actions in milliseconds
	*/
	
	public var coolDown:Int = 100;//milliseconds 

	public var rl:Array<Region>;

	/**
	* data storage for sharing information between components and actors
	*/
	public var data:Units;

	/**
	* data storage for sharing information between components and actors
	*/
	public var buildingData:Buildings;

	/**
	* data of the building you're building
	*/
	public var buildData:Buildings;
	public var buildNode:INode;
	public var queue:Array<UnitData>;
	public var ready:Bool = true;//set to true because most units show up ready, buildings on the other had do not

	/**
	* data storage for sharing information between components and actors
	*/
	public var resourceData:Resources;

	public var currentResource:String;
	public var resourcesCollected:Int;
	public var targetResource:Actor;
	/**
	* resource value or build progress value
	**/
	public var value:Int;

	public static var maxID:Int = 0;

	public var currentState:String;
	public var nextState:String;
	public var lastState:String;


	public function new(node:Node,  data:DataType, id:Int = -1)
	{
		super();
		x = node.x;
		y = node.y;
		if(id == -1)
			this.id = maxID++;
		else
		{
			this.id = id;
			if(id > maxID)
				maxID = id;
		}
		addComponent(new EventDispatcher());
		var image:Image;
		switch (data.type)
		{
			case First(uData):
				this.data = uData;
				image = Reflect.field(Assets.images, uData.image);
				rl = Atlas.createRegionList(image, uData.width, uData.height);
				health = uData.health;
				healthMax = uData.healthMax;
				for(i in uData.comps)
				{
					var ref = i.name;
					addComponent(ComponentSystem.getInstance().getC(ref.name));
				}
			case Second(bData):
				buildingData = bData;
				ready = buildingData.built;
				image = Reflect.field(Assets.images, bData.image);
				rl = Atlas.createRegionList(image, bData.width, bData.height);
				health = bData.health;
				healthMax = bData.healthMax;
				for(i in bData.comps)
				{
					var ref = i.name;
					addComponent(ComponentSystem.getInstance().getC(ref.name));
				}
			case Third(rData):
				resourceData = rData;
				image = Reflect.field(Assets.images, rData.image);
				rl = Atlas.createRegionList(image, rData.width, rData.height);
				health = rData.health;
				healthMax = rData.healthMax;
				value = rData.resourceValue;
				for(i in rData.comps)
				{
					var ref = i.name;
					addComponent(ComponentSystem.getInstance().getC(ref.name));
				}
		}
		graphic = new Sprite(rl[0]);
		setSizeAuto();
		setupNodes(node);
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
		if(currentNodes.length == 1)
		{
			neighbors =  currentNodes[0].getNodeNeighbors();
		}
		else
		{
			neighbors = [];
			for(i in currentNodes)
			{
				for(j in i.neighbors)
				{
					var node:Node = cast (j, Node);
					if(neighbors.indexOf(node) == -1 && node.occupant != this)
					{
						neighbors.push(node);
					}
				}
			}
		}
	}	
	/**
	 * ensures the Actor's actions are removed and that the Actor is no longer on the field
	 * also detatches components
	 */
	public function kill()
	{
		alive = false;
		if(team != null && data != null)
			team.units.remove(this);
		else if(team != null && buildingData != null)
			team.buildings.remove(this);
		for(i in currentNodes)
		{
			i.occupant = null;
		}
		
		for(i in components)
		{
			i.destroy();
		}
	}
}