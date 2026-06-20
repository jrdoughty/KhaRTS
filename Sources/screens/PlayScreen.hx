package screens;

import save.SaveManager;
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
	public var teamsMap(default,null):Map<Int,Team> = new Map<Int,Team>();
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

		var team = new Team();
		if(activeTeam == null)//temp, make active team first team
			activeTeam = team;
		teams.push(team);
		teamsMap[0] = activeTeam;
		var gsd:GameSaveData = null;//SaveManager.load();

		Sdg.addTimeTask(function(){
			//trace(SaveManager.load());
			//SaveManager.save(cast Sdg.screen);
			//trace(SaveManager.load());
		},10,1);
		lvl = new Level(Data.levels.get(demo).tmxFile, Data.levels.get(demo).tsxFile);
		AStar.setLevel(lvl);
		add(lvl);
		lvl.setSizeAuto();
		setWorldSize(lvl.width,lvl.height);
		if(gsd == null)
		{
			setupFromLvlData();
		}
		else 
		{
			setupFromSave(gsd);
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
	
	private function setupFromSave(gsd:GameSaveData) 
	{
		var actor:Actor = null;
		var actorsWithTargets:Array<Actor> = [];
		var actorDataWithTargets:Array<ActorSaveData> = [];
		var actorMap:Map<Int,Actor> = new Map<Int,Actor>();

		for(a in gsd.actors)
		{
			if(a.type == "unit")
			{
				actor = new Actor(lvl.getNodeByGridXY(a.x,a.y),Data.units.get(cast a.data),a.id);
				add(actor);
			}
			else if(a.type == "building")
			{
				actor = new Actor(lvl.getNodeByGridXY(a.x,a.y),Data.buildings.get(cast a.data),a.id);
				cast(Sdg.screen,PlayScreen).add(cast(Sdg.screen,PlayScreen).activeTeam.addUnit(actor));
			}
			else if(a.type == "resource")
			{	
				actor = new Actor(lvl.getNodeByGridXY(a.x,a.y),Data.resources.get(cast a.data),a.id);
				resources.push(actor);
			}
			
			if(actor != null)
			{
				add(actor);
				actorMap.set(actor.id,actor);
				if(a.tx != null)
					actor.targetNode = lvl.getNodeByGridXY(a.tx,a.ty);
				if(a.bx != null)
					actor.buildNode = lvl.getNodeByGridXY(a.bx,a.by);
				actor.currentResource = a.currentResource;
				actor.value = a.value;
				if(a.currentState != null)
					actor.currentState = a.currentState;
				if(a.lastState != null)
					actor.lastState = a.lastState;
				if(a.nextState != null)
					actor.nextState = a.nextState;
				actor.health = a.health;
				if(a.bData != null)
				{
					actor.buildData = Data.buildings.get(cast a.bData);
				}
				if(a.targetResource != null || a.targetEnemy != null || a.targetBuilding != null)
				{
					actorsWithTargets.push(actor);
					actorDataWithTargets.push(a);
				}
				
				if(a.teamID != null && !teamsMap.exists(a.teamID))
				{
					teamsMap[a.teamID] = new Team();
					teams.push(teamsMap[a.teamID]);
					teamsMap[a.teamID].addUnit(actor);
				}
				else if(a.teamID != null)
				{
					teamsMap[a.teamID].addUnit(actor);
				}
			}
		}
		for( i in 0...actorsWithTargets.length)
		{
			if(actorDataWithTargets[i].targetBuilding != null)
			{
				actorsWithTargets[i].targetBuilding = actorMap[i];	
			}
			if(actorDataWithTargets[i].targetEnemy != null)
			{
				actorsWithTargets[i].targetEnemy = actorMap[i];
			}
			if(actorDataWithTargets[i].targetResource != null)
			{
				actorsWithTargets[i].targetResource = actorMap[i];				
			}
		}

	}
	
	private function setupFromLvlData() 
	{
		var startNode;
		var act:Actor;
		for(i in lvl.resourcePos)
		{
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Data.resources.get(tree));
			add(act);
			resources.push(act);
		}
		var team = new Team();
		for(i in lvl.neutralEnemyPos)
		{
			startNode = lvl.getNodeByGridXY(Std.int(i.x), Std.int(i.y));
			act = new Actor(startNode, Data.units.get(enemy));
			add(team.addUnit(act));
		}
		teams.push(team);

		for(i in lvl.playerStartPos.keys())
		{
			for(k in 0...1)
			{
				startNode = lvl.getNodeByGridXY(Std.int(lvl.playerStartPos[i].x+(k % 3)),Std.int(lvl.playerStartPos[i].y+(Math.floor(k / 3))));
				act = new Actor(startNode, Data.units.get(worker));
				add(activeTeam.addUnit(act));
			}	
		}
	}
}