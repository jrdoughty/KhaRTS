package world;

import kha.Assets;
import format.tmx.Reader;
import format.tmx.Data.TmxMap;
import sdg.graphics.tiles.Tilemap;
import sdg.Object;
import world.Node;
import sdg.graphics.tiles.Tilemap;
import events.HideEvent;
import events.RevealEvent;
import kha.math.Vector2;
/**
 * ...
 * @author John Doughty
 */
class Level extends Object
{
	public var activeNodes:Array<Node> = [];

	public var tileset:RTSTileset;
	public var levelWidth:Int;
	public var levelHeight:Int;
	public var playerStartPos:Map<Int, Vector2> = new Map<Int, Vector2>();
	public var neutralEnemyPos:Array<Vector2> = [];
	public var resourcePos:Array<Vector2> = [];

	private var diagonal:Bool = true;
	public function new(tmxFileName:String, tilesetTSXFileName:String) 
	{
		super();
		var r = new Reader(Xml.parse(Reflect.field(Assets.blobs,tmxFileName+"_tmx").toString()));
		var t:TmxMap = r.read();
		levelWidth = t.width;
		levelHeight = t.height;
		tileset = new RTSTileset(tilesetTSXFileName);
		var bgMap = new Tilemap(tileset);
		var i = -1;
		var data = new Array<Array<Int>>();
		for(layer in t.layers)
		{
			switch(layer)
			{
				case TileLayer(layer):
					if(layer.name == 'Background')
					{
						i = 0;
						var count:Int = 0;
						for(y in 0...layer.height)	
						{
							data.push(new Array<Int>());
						
							for (x in 0...layer.width)
							{
								data[y].push(layer.data.tiles[i].gid - 1);//need to use FirstGID instead
								var shouldPass = true;
								var canSee = true;
								for(k in tileset.specialTiles)//can probably be made more efficient
								{
									if(layer.data.tiles[i].gid - 1 == k.id && k.type == 'wall')
									{
										shouldPass = false;
										canSee = false;
									}
									if(layer.data.tiles[i].gid - 1 == k.id && k.type == 'water')
									{
										shouldPass = false;
									}
								} 
								activeNodes.push(new Node(layer.data.tiles[i].gid - 1, t.tileWidth, t.tileHeight, x, y, shouldPass, canSee));
								i++;
							} 
						}
						createNeighbors(t.width,t.height);
						bgMap.loadFrom2DArray(data);
						graphic = bgMap;
					}
					else if (layer.name.indexOf('Player') != -1)
					{
						var player = Std.parseInt(layer.name.substr(6,2));
						i = -1;
						for(tile in layer.data.tiles)
						{
							i++;
							if(tile.gid>0)
							{
								if(!playerStartPos.exists(player))//forces single start point
								{
									playerStartPos.set(player, new Vector2(i%levelWidth,Std.int(i/levelWidth)));
								}
							}
						}
					}
					else if (layer.name.indexOf('Enemy') != -1)
					{
						i = 0;
						for(y in 0...layer.height)	
						{						
							for (x in 0...layer.width)
							{
								if(layer.data.tiles[i].gid > 0)
									neutralEnemyPos.push(new Vector2(x,y));
								i++;
							} 
						}
					}
					else if (layer.name.indexOf('Wood') != -1)
					{
						i = 0;
						for(y in 0...layer.height)	
						{						
							for (x in 0...layer.width)
							{
								if(layer.data.tiles[i].gid > 0)
									resourcePos.push(new Vector2(x,y));
								i++;
							} 
						}
					}
				default:
			}
		}
	}
	
	public function getNodeByGridXY(x:Int,y:Int):Node
	{
		var result:Node = null;
		var index:Int = x + y * levelWidth;
		if (activeNodes.length > index)
		{
			result = activeNodes[index];
		}
		return result;
	}
	
	public function createNeighbors(levelW, levelH)
	{
		var i:Int;
		var j:Int;
		levelWidth = levelW;
		levelHeight = levelH;
		for (i in 0...levelW) 
		{
            for (j in 0...levelH) 
			{
				activeNodes[i + j * levelW].neighbors = [];
				if (diagonal)
				{
					if (i - 1 >= 0 && j - 1 >= 0) 
					{
						activeNodes[i + j * levelW].neighbors.push(activeNodes[i - 1 + (j - 1) * levelW]);
					}
					if (i + 1 < levelW && j - 1 >= 0) 
					{
						activeNodes[i + j * levelW].neighbors.push(activeNodes[i + 1 + (j - 1) * levelW]);
					}
					if (i - 1 >= 0 && j + 1 < levelH) 
					{
						activeNodes[i + j * levelW].neighbors.push(activeNodes[i - 1 + (j + 1) * levelW]);
					}
					if (i + 1 < levelW && j + 1 < levelH) 
					{
						activeNodes[i + j * levelW].neighbors.push(activeNodes[i + 1 + (j + 1) * levelW]);
					}
				}
                if (j - 1 >= 0) 
				{
                    activeNodes[i + j * levelW].neighbors.push(activeNodes[i + (j - 1) * levelW]);
					activeNodes[i + j * levelW].topNode = activeNodes[i + (j - 1) * levelW];
                }
                if (i - 1 >= 0) 
				{
                    activeNodes[i + j * levelW].neighbors.push(activeNodes[i - 1 + j * levelW]);
					activeNodes[i + j * levelW].leftNode = activeNodes[i - 1 + j * levelW];
                }
                if (i + 1 < levelW) 
				{
                    activeNodes[i + j * levelW].neighbors.push(activeNodes[i + 1 + j * levelW]);
					activeNodes[i + j * levelW].rightNode = activeNodes[i + 1 + j * levelW];
                }
                if (j + 1 < levelH) 
				{
                    activeNodes[i + j * levelW].neighbors.push(activeNodes[i + (j + 1) * levelW]);
					activeNodes[i + j * levelW].bottomNode = activeNodes[i + (j + 1) * levelW];
                }
            }
        }
	}

	public function resetFog()
	{
		for(i in activeNodes)
		{
			i.addOverlay();
		}
	}
	public function recreateFog(fogOfWarGraphic:Tilemap)
	{
		for(i in activeNodes)
		{
			if(i.removeShadow)
			{
				fogOfWarGraphic.map[i.nodeY][i.nodeX] = 0;
				if(i.occupant != null)
					i.occupant.eventDispatcher.dispatchEvent(RevealEvent.REVEAL, new RevealEvent());
			}
			else
			{
				if(i.shadowHasBeenRemoved)
					fogOfWarGraphic.map[i.nodeY][i.nodeX] = 1;
				else
					fogOfWarGraphic.map[i.nodeY][i.nodeX] = 2;
				if(i.occupant != null)
					i.occupant.eventDispatcher.dispatchEvent(HideEvent.HIDE, new HideEvent());
			}
		}
	}
}