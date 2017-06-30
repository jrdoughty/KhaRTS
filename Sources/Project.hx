package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;
import sdg.Engine;
import sdg.manager.GamePadMan;
import sdg.Sdg;
import screens.PlayScreen;
import sdg.manager.Manager.*;

class Project {
	public function new() {
		Assets.loadEverything(assetsLoaded);
	}

	function assetsLoaded()
	{
		var engine = new Engine(1280, 720);
		engine.enable(KEYBOARD | MOUSE | GAMEPAD | DELTA);
		loadData();
		Sdg.addScreen('Play', new PlayScreen(), true);

		System.notifyOnRender(engine.render);
		Scheduler.addTimeTask(engine.update, 0, 1 / 60);
		
	}

	function loadData()
	{
		var dataObj:Dynamic = haxe.Json.parse(Assets.blobs.database_cdb.toString());
		var dataMap: Map<String, Map<String, Map<String, Dynamic>>> = new Map<String, Map<String, Map<String, Dynamic>>>();
		var sheets = [];
		sheets = dataObj.sheets;
		for(sheet in sheets)
		{
			dataMap.set(sheet.name, new Map<String, Map<String, Dynamic>>());
			var lines:Array<Dynamic> = sheet.lines;
			for(line in lines)
			{
				dataMap[sheet.name].set(line.name, new Map<String, Dynamic>());
				for(i in Reflect.fields(line))
				{
					dataMap[sheet.name][line.name].set(i, Reflect.field(line,i));
				}
			}
		}
		systems.Data.dataMap = dataMap;
	}
}
