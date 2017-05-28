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
import events.ClearFogEvent;
import events.HideEvent;
import events.RevealEvent;

class PlayScreen extends Screen implements IGameScreen
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
		lvl.setSizeAuto();
		setWorldSize(lvl.width,lvl.height);
		var act = new Actor(lvl.getNodeByGridXY(20,6), Assets.images.knight);
		activeTeam.addUnit(act);
		//var act3 = new Actor(lvl.getNodeByGridXY(3,5), Assets.images.knight);
		//activeTeam.addUnit(act3);
		var act2 = new Actor(lvl.getNodeByGridXY(13,15), Assets.images.redknight);
		teams[1].addUnit(act2);
		add(act);
		add(act2);
		//add(act3);
		var tileset = new Tileset(Assets.images.fogtiles, 32, 32);
		var bgMap = new Fog(tileset);
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
			i.addOverlay();
		}
		for(i in activeTeam.units)
		{
			i.eventDispatcher.dispatchEvent(ClearFogEvent.CLEAR, new ClearFogEvent());
		}
		for(i in lvl.activeNodes)
		{
			if(i.removeShadow)
			{
				cast(fogOfWar.graphic, Tilemap).map[i.nodeY][i.nodeX] = 0;
				if(i.occupant != null)
					i.occupant.eventDispatcher.dispatchEvent(RevealEvent.REVEAL, new RevealEvent());
			}
			else
			{
				cast(fogOfWar.graphic, Tilemap).map[i.nodeY][i.nodeX] = 1;
				if(i.occupant != null)
					i.occupant.eventDispatcher.dispatchEvent(HideEvent.HIDE, new HideEvent());
			}
		}

	}
}