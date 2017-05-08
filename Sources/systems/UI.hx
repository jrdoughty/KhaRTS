package systems;

import sdg.Object;
import sdg.graphics.Sprite;
import kha.Assets;
import sdg.Sdg;
import sdg.ObjectList;
import actors.Actor;
import systems.UIElement;

class UI
{
	public var uiElements:ObjectList;
	private var dashboard:Object;
	private var units:Array<UIElement> = [];

	public function new()
	{
		uiElements = new ObjectList(0,0);
		dashboard = new Dashboard(0,592, new Sprite(Assets.images.dashui));
		uiElements.add(dashboard);
		uiElements.apply(Sdg.screen.add);
	}

	public function setUnits(actors:Array<Actor>)
	{
		for(i in units)
		{
			uiElements.remove(i);
			Sdg.screen.remove(i,true);
		}
		units = [];
		for(i in 0...actors.length)
		{
			var spr = new Sprite(cast(actors[i].graphic, Sprite).region);
			units.push(new UIElement((i * 32) % 128 + dashboard.x, Math.floor(i/4)*32 + dashboard.y, spr));
			uiElements.add(units[i]);
		}
		uiElements.apply(Sdg.screen.add);
	}
}