package systems;

import actors.Actor;
import sdg.graphics.Sprite;
import systems.UIElement;
import sdg.Sdg;
import components.UIHealth;

class ActorRepresentative extends UIElement
{
	public var actor:Actor;
	private var spr:Sprite;

	public function new(x:Float, y:Float, a:Actor)
	{
		actor = a;
		spr = new Sprite(cast(a.graphic, Sprite).region);
		super(x, y, spr);
		addComponent(new UIHealth(a));
		leftClick = click;
	}

	public function kill()
	{
		Sdg.screen.remove(this, true);
	}

	private function click(x:Float, y:Float)
	{
		Sdg.screen.camera.x = actor.x - Sdg.screen.camera.halfWidth;
		Sdg.screen.camera.y = actor.y - Sdg.screen.camera.halfHeight;
		if(Sdg.screen.camera.x < 0) Sdg.screen.camera.x = 0; 
		if(Sdg.screen.camera.y < 0) Sdg.screen.camera.y = 0; 
		//make event to trigger ui recentering
	}
}