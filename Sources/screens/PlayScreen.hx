package screens;

import kha.Assets;
import sdg.Screen;
import actors.Actor;
import world.Level;
import systems.AStar;

class PlayScreen extends Screen
{
	public var lvl:Level = new Level();
	public function new()
	{
		super();
	}
	public override function init()
	{
		super.init();

		lvl = new Level();
		AStar.setLevel(lvl);
		add(lvl);
		add(new Actor(lvl.activeNodes[0], Assets.images.knight));
	}
}