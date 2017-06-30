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
import sdg.components.Component;
import components.StateAI;
import components.Health;
import components.BasicAnimator;
import components.View;
import events.ClearFogEvent;
import events.HideEvent;
import events.RevealEvent;
import sdg.atlas.Atlas;

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
		var data: Map<String, Dynamic> = systems.Data.dataMap['units']['soldier'];
		var image:kha.Image = Reflect.field(Assets.images, data['image']);
		var rl = Atlas.createRegionList(image, 32, 32);
		var cl:Array<Component> = [new BasicAnimator(rl), new Health(), new StateAI(), new View()];
		var act = new Actor(lvl.getNodeByGridXY(14,5), rl, cl, data);
		activeTeam.addUnit(act);
		
		rl = Atlas.createRegionList(Assets.images.redknight,32,32);
		cl = [new BasicAnimator(rl), new Health(), new StateAI(), new View()];
		data = [
			"threatRange"=> 3,
			"speed" => 500,
			"aggressive" => false,
			"mobile" => true,
			"damage" => 2,
			"health" => 1,
			'viewRange' => 4
			];
		var act2 = new Actor(lvl.getNodeByGridXY(14,10), rl, cl, data);
		teams[1].addUnit(act2);
		
		rl = Atlas.createRegionList(Assets.images.tree,64,64);
		cl = [];
		data = ["wood" => 5];
		var act3 = new Actor(lvl.getNodeByGridXY(14,2), rl, cl, data);
		add(act3);
		teams[1].addUnit(act3);//temporary

		add(act);
		add(act2);
		
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