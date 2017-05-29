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
import sdg.graphics.tiles.Tileset;
import sdg.Sdg;

class Fog extends Tilemap
{	
	private static inline var TOP_LEFT = 1;
	private static inline var TOP_RIGHT = 2;
	private static inline var BOTTOM_LEFT = 4;
	private static inline var BOTTOM_RIGHT = 8;

	private var bBuffer:Image;

	public function new(tileset:Tileset)
	{
		super(tileset);
		bBuffer= Image.createRenderTarget(Sdg.screen.camera.width, Sdg.screen.camera.height);
	}

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
		canvas.g2.end();
		bBuffer.g2.begin(true, kha.Color.Transparent);
		for (r in _startRow...(_endRow))
		{
			for (c in _startCol...(_endCol))
			{
				drawArea(r, c, bBuffer, objectX, objectY, cameraX, cameraY);
			}
		}
		
		bBuffer.g2.end();
		canvas.g2.begin(false);
		canvas.g2.drawImage(bBuffer,0, 0);
		canvas.g2.opacity = 1;
	}

	private function drawArea(r:Int, c:Int, canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float)
	{
		var fullTW = tileset.tileWidth;
		var halfTW = fullTW/2;
		var quarTW = fullTW/4;
		var fullTH = tileset.tileHeight;
		var halfTH = fullTH/2;
		var quarTH = fullTH/4;
		_px = objectX + x + (c * fullTW) - cameraX;
		_py = objectY + y + (r * fullTH) - cameraY;
		
		var config:Int = 0;
		if(map[r][c] == 0) config += TOP_LEFT;
		if(c < map[r].length && map[r][c+1] == 0) config += TOP_RIGHT;
		if(r < map.length && c < map[r].length && map[r+1][c+1] == 0) config += BOTTOM_RIGHT;
		if(r < map.length && map[r+1][c] == 0) config += BOTTOM_LEFT;
		
		canvas.g2.color = kha.Color.Black;
		
		switch config {
			case 0: 
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py, fullTW, fullTH);
			case 1:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW, _py, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + quarTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + quarTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, halfTW, fullTH);
				canvas.g2.fillRect(_px, _py + halfTW, halfTW, halfTH);
			case 2:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW + halfTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + halfTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py, halfTW, fullTH);
				canvas.g2.fillRect(_px + halfTW, _py + halfTW, halfTW, halfTH);
			case 3://TOP_LEFT | TOP_RIGHT:
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py + halfTH, fullTW, halfTH);
			case 4:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW, _py + quarTH + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + halfTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + quarTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, halfTW, fullTH);
				canvas.g2.fillRect(_px, _py, halfTW, halfTH);
			case 5://TOP_LEFT | BOTTOM_LEFT:
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + halfTW, _py, halfTW, fullTH);
			case 6:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW + halfTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, quarTW, quarTH);
				canvas.g2.fillRect(_px + quarTW, _py + quarTH + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + halfTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + quarTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py, halfTW, halfTH);
				canvas.g2.fillRect(_px + halfTW, _py + halfTH, halfTW, halfTH);
			case 7://TOP_LEFT | TOP_RIGHT | BOTTOM_LEFT:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + halfTW + quarTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py + halfTH + quarTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + halfTW + quarTW, _py + halfTH + quarTH, quarTW, quarTH);
			case 8:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW + halfTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py + quarTH + halfTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + halfTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py, halfTW, fullTH);
				canvas.g2.fillRect(_px + halfTW, _py, halfTW, halfTH);
			case 9://TOP_LEFT | BOTTOM_RIGHT:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW, _py, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + quarTW + halfTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py + quarTH + halfTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + halfTW, _py + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + quarTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, halfTW, halfTH);
				canvas.g2.fillRect(_px, _py + halfTH, halfTW, halfTH);
			case 10://TOP_RIGHT | BOTTOM_RIGHT:
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py, halfTW, fullTH);
			case 11://TOP_LEFT | TOP_RIGHT | BOTTOM_RIGHT:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW, _py + quarTH + halfTH, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + halfTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py + quarTH + halfTH, quarTW, quarTH);
			case 12://BOTTOM_LEFT | BOTTOM_RIGHT:
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py, fullTW, halfTH);
			case 13://TOP_LEFT | BOTTOM_LEFT | BOTTOM_RIGHT:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW + halfTW, _py + quarTH, quarTW, quarTH);
				canvas.g2.fillRect(_px + halfTW, _py, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px + quarTW + halfTW, _py, quarTW, quarTH);
			case 14://TOP_RIGHT | BOTTOM_LEFT | BOTTOM_RIGHT:
				canvas.g2.opacity = .25;
				canvas.g2.fillRect(_px + quarTW, _py, quarTW, quarTH);
				canvas.g2.fillRect(_px, _py + quarTH, quarTW, quarTH);
				canvas.g2.opacity = .5;
				canvas.g2.fillRect(_px, _py, quarTW, quarTH);
			default:
		}
	}

	private function drawbasic(canvas:kha.Canvas, _px:Float, _py:Float)
	{
		canvas.g2.color = kha.Color.Black;
		canvas.g2.opacity = .5;
		canvas.g2.fillRect(_px, _py, 64, 64);
	}
}