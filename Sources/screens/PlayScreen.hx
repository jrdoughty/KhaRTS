package screens;

import haxe.Timer;
import systems.InputSystem;
import kha.Assets;
import sdg.Screen;
import sdg.Object;
import sdg.event.EventObject;
import actors.Actor;
import world.Level;
import sdg.pathfinding.AStar;
import systems.Team;
import graphics.Fog;
import sdg.graphics.tiles.Tilemap;
import sdg.components.Component;
import events.SimpleEvents;
import sdg.atlas.Atlas;
import sdg.graphics.text.Text;
import kha.Assets;
import systems.Data;
import sdg.Sdg;

class PlayScreen extends Screen implements IGameScreen
{
	public var lvl:Level;	
	public var teams(default,null):Array<Team> = [];
	public var activeTeam(default,null):Team;
	public var dashboard(default,null):Object;
	public var inputSystem:InputSystem;
	public var fogOfWar:Object;
	public var fogGraphic:Fog;
	public var resourcesText:Text;
	public var fpsText:Text;
	public var fps:Int =0;
	public var fpsTimer:Int;
	public var resources:Array<Actor> = [];
	
	public function new()
	{
		super();
	}
	public override function init()
	{
		super.init();

		var startNode;
		var act:Actor;
		var team;
		lvl = new Level(Data.levels.get(demo).tmxFile, Data.levels.get(demo).tsxFile);
		AStar.setLevel(lvl);
		add(lvl);
		lvl.setSizeAuto();
		setWorldSize(lvl.width,lvl.height);
		for(i in lvl.resourcePos)
		{
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Data.resources.get(tree));
			add(act);
			resources.push(act);
		}
		team = new Team();
		for(i in lvl.neutralEnemyPos)
		{
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Data.units.get(enemy));
			add(team.addUnit(act));
		}
		teams.push(team);
		for(i in lvl.playerStartPos.keys())
		{
			team = new Team();
			if(activeTeam == null)//temp, make active team first team
				activeTeam = team;
			teams.push(team);
			for(k in 0...1)
			{
				startNode = lvl.getNodeByGridXY(Std.int(lvl.playerStartPos[i].x+(k % 3)),Std.int(lvl.playerStartPos[i].y+(Math.floor(k / 3))));
				act = new Actor(startNode, Data.units.get(worker));
				add(team.addUnit(act));
			}	
		}
		
		fogGraphic = new Fog(lvl.tileset);
		var data:Array<Array<Int>> = [];

		for(y in 0...lvl.levelHeight)
		{
			data.push(new Array<Int>());
			for(x in 0...lvl.levelWidth)
			{
				data[y].push(1);
			}
		}
		fogGraphic.loadFrom2DArray(data);
		fogOfWar = new Object(0,0,fogGraphic);
		add(fogOfWar);
		dashboard = new Object();
		inputSystem = new InputSystem(this);
		resourcesText = new Text('test',Assets.fonts.OAG, 8, 50);
		fpsText = new Text('test',Assets.fonts.OAG, 8, 50);
		var o = create(4,4,resourcesText);
		o.fixed.x = true;
		o.fixed.y = true;
		o = create(304,4,fpsText);
		o.fixed.x = true;
		o.fixed.y = true;

		fpsTimer = Sdg.addTimeTask(fpsTick, 1,0,1);
	}

	public function fpsTick() 
	{
		fpsText.text = Std.string(fps);
		fps = 0;
	}
	public override function update()
	{
		super.update();
		lvl.resetFog();
		for(i in activeTeam.units)
		{
			i.eventDispatcher.dispatchEvent(SimpleEvents.CLEAR, new EventObject());
		}
		lvl.recreateFog(fogGraphic);
		resourcesText.text = activeTeam.resources+"";
		inputSystem.update();		
		fps++;
	}

	public override function close()
	{
		super.close();
		lvl = null;
		teams = [];
		activeTeam = null;
		inputSystem.close();
		inputSystem = null;
		fogOfWar = null;
		resourcesText = null;
		
	}
}