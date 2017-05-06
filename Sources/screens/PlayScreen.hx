package screens;

import systems.InputSystem;
import kha.Assets;
import sdg.Screen;
import sdg.Object;
import actors.Actor;
import world.Level;
import systems.AStar;
import systems.Team;

class PlayScreen extends Screen implements IGameState
{
	public var lvl:Level = new Level();	
	public var teams(default,null):Array<Team> = [];
	public var activeTeam(default,null):Team;
	public var dashboard(default,null):Object;
	public var inputSystem:InputSystem;
	public function new()
	{
		super();
	}
	public override function init()
	{
		super.init();
		activeTeam = new Team();
		teams.push(activeTeam);
		teams.push(new Team());
		lvl = new Level();
		AStar.setLevel(lvl);
		add(lvl);
		var act = new Actor(lvl.activeNodes[0], Assets.images.knight);
		activeTeam.addUnit(act);
		var act3 = new Actor(lvl.activeNodes[1], Assets.images.knight);
		activeTeam.addUnit(act3);
		var act2 = new Actor(lvl.activeNodes[109], Assets.images.redknight);
		teams[1].addUnit(act2);
		add(act);
		add(act2);
		add(act3);

		dashboard = new Object();
		inputSystem = new InputSystem(this);
	}

	public override function update()
	{
		super.update();
		inputSystem.update();
		camera.center(500, 100);
	}
}