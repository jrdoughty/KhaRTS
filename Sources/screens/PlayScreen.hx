package screens;

import systems.InputSystem;
import kha.Assets;
import sdg.Screen;
import sdg.Object;
import sdg.event.EventObject;
import actors.Actor;
import world.Level;
import systems.AStar;
import systems.Team;
import graphics.Fog;
import sdg.graphics.tiles.Tilemap;
import sdg.components.Component;
import events.SimpleEvents;
import sdg.atlas.Atlas;
import sdg.graphics.text.Text;
import kha.Assets;

class PlayScreen extends Screen implements IGameScreen
{
	public var lvl:Level;	
	public var teams(default,null):Array<Team> = [];
	public var activeTeam(default,null):Team;
	public var dashboard(default,null):Object;
	public var inputSystem:InputSystem;
	public var fogOfWar:Object;
	public var resourcesText:Text;
	
	public function new()
	{
		super();
	}
	public override function init()
	{
		super.init();

		var startNode;
		var act;
		var team;
		lvl = new Level(systems.Data.dataMap['levels']['demo']['tmxFile'], systems.Data.dataMap['levels']['demo']['tsxFile']);
		AStar.setLevel(lvl);
		add(lvl);
		lvl.setSizeAuto();
		setWorldSize(lvl.width,lvl.height);
		for(i in lvl.resourcePos)
		{
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Util.cloneStringMap(systems.Data.dataMap['resources']['tree']));
			add(act);
		}
		for(i in lvl.neutralEnemyPos)
		{
			//break;
			team = new Team();
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Util.cloneStringMap(systems.Data.dataMap['units']['enemy']));
			add(team.addUnit(act));
		}
		for(i in lvl.playerStartPos.keys())
		{
			team = new Team();
			if(activeTeam == null)//temp, make active team first team
				activeTeam = team;
			teams.push(team);
			for(k in 0...1)
			{
				startNode = lvl.getNodeByGridXY(Std.int(lvl.playerStartPos[i].x+(k % 3)),Std.int(lvl.playerStartPos[i].y+(Math.floor(k / 3))));
				act = new Actor(startNode, Util.cloneStringMap(systems.Data.dataMap['units']['worker']));
				add(team.addUnit(act));
			}	
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
		resourcesText = new Text('test', Assets.fonts.OAG, 8, 50);
		var o = create(4,4,resourcesText);
		o.fixed.x = true;
		o.fixed.y = true;
	}

	public override function update()
	{
		super.update();
		lvl.resetFog();
		for(i in activeTeam.units)
		{
			i.eventDispatcher.dispatchEvent(SimpleEvents.CLEAR, new EventObject());
		}
		lvl.recreateFog(cast(fogOfWar.graphic, Tilemap));
		inputSystem.update();
		resourcesText.text = activeTeam.resources+"";
		
	}
}