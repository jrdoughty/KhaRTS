package graphics;

import sdg.Graphic;
import kha.Image;
import kha.Canvas;
import kha.math.Vector2i;
import sdg.math.Vector2b;
import sdg.atlas.Atlas;
import sdg.atlas.Region;
import sdg.Graphic.ImageType;
using kha.graphics2.GraphicsExtension;
import sdg.graphics.tiles.Tilemap;
import sdg.Sdg;

class Fog extends Tilemap
{	
	private static inline var TOP_LEFT = 1;
	private static inline var TOP_RIGHT = 2;
	private static inline var BOTTOM_LEFT = 4;
	private static inline var BOTTOM_RIGHT = 8;
	override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		canvas.g2.color = color;
		
		if 	(((x + widthInPixels) < cameraX) || (x > (cameraX + Sdg.gameWidth)) ||
			((y + heightInPixels) < cameraY) || (y > (cameraY + Sdg.gameHeight)))
				return;		   
		
		_startCol = Math.floor((x > cameraX ? 0 : (cameraX - x)) / tileset.tileWidth);
		_endCol = Std.int(((x + widthInPixels) > (cameraX + Sdg.gameWidth) ? (cameraX + Sdg.gameWidth - x) : widthInPixels) / tileset.tileWidth);
		_startRow = Math.floor((y > cameraY ? 0 : (cameraY - y)) / tileset.tileHeight);
		_endRow = Std.int(((y + heightInPixels) > (cameraY + Sdg.gameHeight) ? (cameraY + Sdg.gameHeight - y) : heightInPixels) / tileset.tileHeight);						
		
		if (_endCol < widthInTiles)
			_endCol++;
			
		if (_endRow < heightInTiles)
			_endRow++;
		var skipX:Bool = false;
		for (r in _startRow...(_endRow))
		{
			if(!skipX)
			{
				var skipY:Bool = false;
				for (c in _startCol...(_endCol))
				{
					if(!skipY)
						drawArea(r, c, canvas, objectX, objectY, cameraX, cameraY);
					//skipY = !skipY;
				}
			}
			//skipX = !skipX;
		}
		canvas.g2.opacity = 1;
	}

	private function drawArea(r:Int, c:Int, canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float)
	{
		var tile = map[r][c];
		if (tile != -1)
		{
			_px = objectX + x + (c * tileset.tileWidth) - cameraX;
			_py = objectY + y + (r * tileset.tileHeight) - cameraY;
			
			var config:Int = 0;
			if(map[r][c] == 0) config += TOP_LEFT;
			if(c < map[r].length && map[r][c+1] == 0) config += TOP_RIGHT;
			if(r < map.length && c < map[r].length && map[r+1][c+1] == 0) config += BOTTOM_RIGHT;
			if(r < map.length && map[r+1][c] == 0) config += BOTTOM_LEFT;
			
			canvas.g2.color = kha.Color.Black;
			
			switch config {
				case 0: 
					canvas.g2.opacity = .5;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth, tileset.tileHeight);
				case 1:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.opacity = .5;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 2:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.opacity = .5;
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 3://TOP_LEFT | TOP_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth, tileset.tileHeight / 2);
				case 4:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.opacity = .5;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 5://TOP_LEFT | BOTTOM_LEFT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight);
				case 6:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 7://TOP_LEFT | TOP_RIGHT | BOTTOM_LEFT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 8:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.opacity = .5;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 9://TOP_LEFT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 10://TOP_RIGHT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight);
				case 11://TOP_LEFT | TOP_RIGHT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py + tileset.tileHeight / 2, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 12://BOTTOM_LEFT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth, tileset.tileHeight / 2);
				case 13://TOP_LEFT | BOTTOM_LEFT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px + tileset.tileWidth / 2, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
				case 14://TOP_RIGHT | BOTTOM_LEFT | BOTTOM_RIGHT:
					canvas.g2.opacity = .25;
					canvas.g2.fillRect(_px, _py, tileset.tileWidth / 2, tileset.tileHeight / 2);
				default:
			}


		}
	}
	private function drawbasic(canvas:kha.Canvas, _px:Float, _py:Float)
	{
		canvas.g2.color = kha.Color.Black;
		canvas.g2.opacity = .5;
		canvas.g2.fillRect(_px, _py, 64, 64);
	}
}