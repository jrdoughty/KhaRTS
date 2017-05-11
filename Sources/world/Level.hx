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
	public var activeNodes = [];
	public var tileset:Tileset;
	public var levelWidth:Int;
	public var levelHeight:Int;

	private var fog:Object;

	private var diagonal:Bool = false;
	public function new() 
	{
		super();
		var r = new Reader(Xml.parse(Assets.blobs.level_tmx.toString()));
		var t:TmxMap = r.read();
		levelWidth = t.width;
		levelHeight = t.height;
		tileset = new Tileset(Assets.images.floors, 32, 32);
		var bgMap = new Tilemap(tileset);
		var i = -1;
		for(layer in t.layers)
		{
			switch(layer)
			{
				case TileLayer(layer):
					if(layer.name == 'Background')
					{
						var data = new Array<Array<Int>>();
						i = 0;
						for(y in 0...layer.height)	
						{
							data.push(new Array<Int>());
						
							for (x in 0...layer.width)
							{
								data[y].push(layer.data.tiles[i].gid - 1);
								activeNodes.push(new Node(layer.data.tiles[i].gid - 1,t.tileWidth, t.tileHeight,x,y,true));
								i++;
							} 
						}
						bgMap.loadFrom2DArray(data);
						graphic = bgMap;
						createNeighbors(t.width,t.height);
					}
					else if (layer.name == 'EnemyLayer')
					{
						i = -1;
						for(tile in layer.data.tiles)
						{
							i++;
							if(tile.gid>0)
							{
								//add(new EnemyAI((i%layer.width) * 32, Std.int(i/layer.width)*32,Assets.images.redknight,32,32));
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
								//add(new Player((i%layer.width) * 32, Std.int(i/layer.width)*32,Assets.images.knight,32,32));
							}
						}
					}
				case ObjectGroup(layer):
					if(layer.name == 'Boundries')
					{
						for(i in layer.objects)
						{
							//trace(i.x);
							var x = Std.int(i.x);
							var y = Std.int(i.y);
							var w = Std.int(i.width);
							var h = Std.int(i.height);
							//walls.push(new Wall(x, y, w, h));
						}
					}
				default:
					trace(layer);

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
	
	public function rebuildFog()
	{
		/*
		for (i in 0...activeNodes.length)
		{
			var sourceRect:Rectangle = new Rectangle(0, 0, activeNodes[i].width, activeNodes[i].height);
			var destPoint:Point = new Point(Std.int(activeNodes[i].x), activeNodes[i].y);
			var btmpdta:BitmapData = activeNodes[i].overlay.updateFramePixels();
			fog.pixels.copyPixels(btmpdta, sourceRect, destPoint, btmpdta, new Point(0,0), false);
		}
		fog.dirty = true;
		*/
	}
}