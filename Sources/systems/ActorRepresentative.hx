package systems;

import actors.Actor;
import sdg.graphics.Sprite;
import systems.UIElement;
import sdg.Sdg;
import components.UIHealth;
import sdg.components.EventDispatcher;
import events.CenterOnUnitEvent;

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
		addComponent(new EventDispatcher());
		leftClick = click;
	}

	public function kill()
	{
		Sdg.screen.remove(this, true);
	}

	private function click(x:Float, y:Float)
	{
		eventDispatcher.dispatchEvent(CenterOnUnitEvent.CENTER, new CenterOnUnitEvent(actor));
		//make event to trigger ui recentering
	}
}