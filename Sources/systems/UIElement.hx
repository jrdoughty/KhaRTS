package systems;

import sdg.Object;
import sdg.Graphic;
import sdg.math.Vector2b;

class UIElement extends Object
{
	

	public var leftClick: Float->Float->Void;
	public var rightClick: Float->Float->Void;
	public var leftDown: Float->Float->Void;
	public var rightDown: Float->Float->Void;

	public function new(x:Float = 0, y:Float = 0, ?graphic:Graphic):Void
	{
		super(x, y, graphic);
		fixed = new Vector2b(true, true);
		setSizeAuto();
		leftClick = function(x:Float, y:Float){};
		rightClick = function(x:Float, y:Float){};
		leftDown = function(x:Float, y:Float){};
		rightDown = function(x:Float, y:Float){};
	}
}