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
		
		for (r in _startRow...(_endRow))
		{
			for (c in _startCol...(_endCol))
			{
				drawArea(r, c, canvas, objectX, objectY, cameraX, cameraY);
			}
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
			


			if(tile > 0)
			{
				canvas.g2.color = kha.Color.Black;
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px,_py,32,32);
			}

		}
	}
}