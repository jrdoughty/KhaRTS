package screens;

import systems.InputSystem;
import kha.Assets;
import sdg.Screen;
import sdg.Object;
import actors.Actor;
import world.Level;
import systems.AStar;
import systems.Team;
import graphics.Fog;
import sdg.graphics.tiles.Tilemap;
import sdg.graphics.tiles.Tileset;

class PlayScreen extends Screen implements IGameState
{
	public var lvl:Level = new Level();	
	public var teams(default,null):Array<Team> = [];
	public var activeTeam(default,null):Team;
	public var dashboard(default,null):Object;
	public var inputSystem:InputSystem;
	public var fogOfWar:Object;
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
		var tileset = new Tileset(Assets.images.fogtiles, 32, 32);
		var bgMap = new Tilemap(tileset);
		var data:Array<Array<Int>> = [];

		for(y in 0...lvl.levelHeight)
		{
			data.push(new Array<Int>());
			for(x in 0...lvl.levelWidth)
			{
				data[y].push(1);
			}
		}
		bgMap.loadFrom2DArray(data);
		fogOfWar = new Object(0,0,bgMap);
		add(fogOfWar);
		dashboard = new Object();
		inputSystem = new InputSystem(this);
	}

	public override function update()
	{
		super.update();
		recreateFog();
		inputSystem.update();
	}

	private function recreateFog()
	{
		for(i in lvl.activeNodes)
		{
			/*
			if(i.occupant == null)
				i.addOverlay();
			else
				i.removeOverlay();
				*/
			cast(fogOfWar.graphic, Tilemap).map[i.nodeY][i.nodeX] = i.occupant == null? 1:0;
		}

	}
}