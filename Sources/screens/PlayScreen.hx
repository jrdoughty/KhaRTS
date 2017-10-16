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
import sdg.components.Component;
import events.ClearFogEvent;
import sdg.atlas.Atlas;

class PlayScreen extends Screen implements IGameScreen
{
	public var lvl:Level;	
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

		lvl = new Level(systems.Data.dataMap['levels']['demo']['tmxFile'], systems.Data.dataMap['levels']['demo']['tsxFile']);
		AStar.setLevel(lvl);
		add(lvl);
		lvl.setSizeAuto();
		setWorldSize(lvl.width,lvl.height);
		for(i in lvl.playerStartPos.keys())
		{
			var team = new Team();
			if(activeTeam == null)//temp, make active team first team
				activeTeam = team;
			teams.push(team);
			
			var startNode = lvl.getNodeByGridXY(Std.int(lvl.playerStartPos[i].x),Std.int(lvl.playerStartPos[i].y));
			var act = new Actor(startNode, Util.cloneStringMap(systems.Data.dataMap['units']['soldier']));
			add(team.addUnit(act));
		}
		
		var bgMap = new Fog(lvl.tileset);
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
		lvl.resetFog();
		for(i in activeTeam.units)
		{
			i.eventDispatcher.dispatchEvent(ClearFogEvent.CLEAR, new ClearFogEvent());
		}
		lvl.recreateFog(cast(fogOfWar.graphic, Tilemap));
		inputSystem.update();
	}
}