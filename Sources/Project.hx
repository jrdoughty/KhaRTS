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
import kha.input.Keyboard;
import kha.input.KeyCode;
import systems.Data;

class Project {
	public function new() {
		Assets.loadEverything(assetsLoaded);
	}

	function assetsLoaded()
	{
		var engine = new Engine(320, 240, false, true, 60);
		engine.enable(KEYBOARD | MOUSE | GAMEPAD | DELTA);
		Data.loadData();
		Sdg.addScreen('Play', new PlayScreen(), true);

		System.notifyOnRender(engine.render);
		Scheduler.addTimeTask(engine.update, 0, 1 / 60);
		Keyboard.get(0).notify(reset, null, null);
	}
	function reset (kc:KeyCode)
	{
		if (kc == KeyCode.Tab)
		{
			Sdg.screen.close();
			Sdg.removeScreen('Play', true);
			Sdg.addScreen('Play', new PlayScreen(), true);
		}
	}
}
