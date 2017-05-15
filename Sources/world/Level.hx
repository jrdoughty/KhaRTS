package world;

import kha.Assets;
import kha.Scheduler;
import format.tmx.Reader;
import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxTileLayer;
import format.tmx.Data.TmxObjectGroup;
import sdg.graphics.tiles.Tileset;
import sdg.graphics.tiles.Tilemap;
import sdg.Object;
import sdg.atlas.Region;
import sdg.graphics.TileSprite;
//import collision.Wall;
import sdg.event.EventSystem;
import actors.Actor;
import world.Node;
/**
 * ...
 * @author John Doughty
 */
class Level extends Object
{
	public var activeNodes:Array<Node> = [];
	public var tileset:Tileset;
	public var levelWidth:Int;
	public var levelHeight:Int;

	private var diagonal:Bool = false;
	public function new() 
	{
		super();
		var r = new Reader(Xml.parse(Assets.blobs.level_tmx.toString()));
		var t:TmxMap = r.read();
		levelWidth = t.width;
		levelHeight = t.height;
		tileset = new Tileset(Assets.images.hyptosistiles, 32, 32);
		var bgMap = new Tilemap(tileset);
		var fgMap = new Tilemap(tileset);
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
						for(y in 0...layer.height)	
						{
							data.push(new Array<Int>());
						
							for (x in 0...layer.width)
							{
								data[y].push(layer.data.tiles[i].gid - 1);//need to use FirstGID instead
								activeNodes.push(new Node(layer.data.tiles[i].gid - 1,t.tileWidth, t.tileHeight,x,y,true));
								i++;
							} 
						}
						createNeighbors(t.width,t.height);
					}
					else if(layer.name == 'Foreground')
					{
						i = 0;
						for(y in 0...layer.height)	
						{						
							for (x in 0...layer.width)
							{
								if(layer.data.tiles[i].gid != 0)
								{
									data[y][x]=layer.data.tiles[i].gid - 1;//need to use FirstGID instead
									getNodeByGridXY(x,y).passable = false;
								}
								i++;
							} 
						}
						bgMap.loadFrom2DArray(data);
						graphic = bgMap;
						//fgMap.loadFrom2DArray(data);
						//graphic = fgMap;
						//createNeighbors(t.width,t.height);
					}
					else if (layer.name == 'EnemyLayer')
					{
						i = -1;
						for(tile in layer.data.tiles)
						{
							i++;
							if(tile.gid>0)
							{
							}
						}
					}
					else if (layer.name == 'PlayerLayer')
					{
						i = -1;
						for(tile in layer.data.tiles)
						{
							i++;
							if(tile.gid>0)
							{
							}
						}
					}
					
				default:
					//trace(layer);
					

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
}