package systems;

import sdg.Object;
import sdg.Graphic;

class UIElement extends Object
{
	

	public var leftClick: Float->Float->Void;
	public var rightClick: Float->Float->Void;
	public var leftDown: Float->Float->Void;
	public var rightDown: Float->Float->Void;

	public function new(x:Float = 0, y:Float = 0, ?graphic:Graphic):Void
	{
		super(x, y, graphic);
		setSizeAuto();
	}
}