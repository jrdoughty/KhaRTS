package systems;

import sdg.Object;
import sdg.Graphic;

interace IUIElement
{
	public function leftClick(x:Float,y:Float):Void;
	public function rightClick(x:Float,y:Float):Void;
	public function leftDown(x:Float,y:Float):Void;
	public function rightDown(x:Float,y:Float):Void;
}