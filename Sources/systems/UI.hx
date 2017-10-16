package systems;

import sdg.Object;
import sdg.graphics.Sprite;
import sdg.atlas.Region;
import kha.Assets;
import sdg.Sdg;
import sdg.ObjectList;
import actors.Actor;
import systems.UIElement;
import events.KillEvent;
import systems.ActorRepresentative;
import events.CenterOnUnitEvent;
import events.AttackInputEvent;
import events.StopInputEvent;
import events.MoveInputEvent;

class UI extends SimpleEventDispatcher
{
	public var uiElements:ObjectList;
	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var dashboard:Object;
	private var units:Array<ActorRepresentative> = [];
	private var focusUnit:ActorRepresentative;
	private var controls:Array<UIElement> = [];

	public function new()
	{
		super();
		uiElements = new ObjectList(0,0);
		dashboard = new Dashboard(0,184, new Sprite(Assets.images.dashui));
		uiElements.add(dashboard);
		uiElements.apply(Sdg.screen.add);

		addEvent(KillEvent.KILL, KillUnit);
		addEvent(CenterOnUnitEvent.CENTER, centerOnActor);
	}

	public function setUnits(actors:Array<Actor>)
	{
		for(i in units)
		{
			uiElements.remove(i);
			Sdg.screen.remove(i,true);
		}
		for(i in controls)
		{
			uiElements.remove(i);
			Sdg.screen.remove(i,true);
		}
		if(focusUnit != null)
		{
			uiElements.remove(focusUnit);
			Sdg.screen.remove(focusUnit, true);
		}
		units = [];
		controls = [];
		focusUnit = null;

		for(i in 0...actors.length)
		{
			units.push(new ActorRepresentative((i * actors[i].width) % (actors[i].width * 6) + dashboard.x, Math.floor(i / 6) * actors[i].height + dashboard.y, actors[i]));
			uiElements.add(units[i]);
			if(actors[i].data['mobile'])
			{
				controls.push(new UIElement(dashboard.width - 96, dashboard.y, new Sprite(new Region(Assets.images.controls,0,0,32,32))));
				controls[controls.length-1].leftClick = function(x:Float,y:Float){dispatchEvent(MoveInputEvent.MOVE, new MoveInputEvent());};
				uiElements.add(controls[controls.length-1]);
			}
			if(actors[i].data['mobile'] || actors[i].data.exists('damage'))
			{
				controls.push(new UIElement(dashboard.width - 64, dashboard.y, new Sprite(new Region(Assets.images.controls,32,0,32,32))));
				controls[controls.length-1].leftClick = function(x:Float,y:Float){dispatchEvent(StopInputEvent.STOP, new StopInputEvent());};
				uiElements.add(controls[controls.length-1]);
			}
			if(actors[i].data.exists('damage'))
			{
				controls.push(new UIElement(dashboard.width - 32, dashboard.y, new Sprite(new Region(Assets.images.controls,64,0,32,32))));
				controls[controls.length-1].leftClick = function(x:Float,y:Float){dispatchEvent(AttackInputEvent.ATTACK, new AttackInputEvent());};
				uiElements.add(controls[controls.length-1]);
			}
		}
		if(units.length > 0)
		{
			focusUnit = units[0].clone((units[0].width * 8), dashboard.y, 4, 4);
			uiElements.add(focusUnit);
		}
		uiElements.apply(Sdg.screen.add);
	}

	public function KillUnit(e:KillEvent)
	{
		var uiElemDied = false;
		for(i in units)
		{
			if(e.actor == i.actor)
			{
				uiElements.remove(i);
				units.remove(i);
				i.kill();
				uiElemDied = true;
				break;
			}
		}
		if(uiElemDied)
		{
			for(i in 0...units.length)
			{
				units[i].x = (i * 8) % 48 + dashboard.x;
				units[i].y = Math.floor(i/6)*8 + dashboard.y;
			}
		}
	}

	public function centerOnActor(e:CenterOnUnitEvent)
	{	
		Sdg.screen.camera.x = e.actor.x - Sdg.screen.camera.halfWidth;
		Sdg.screen.camera.y = e.actor.y - Sdg.screen.camera.halfHeight;
		
		if(Sdg.screen.camera.x < 0) 
			Sdg.screen.camera.x = 0; 
		else if(Sdg.screen.camera.x > Sdg.screen.camera.width + Sdg.gameWidth) 
			Sdg.screen.camera.x = Sdg.gameWidth - Sdg.screen.camera.width; 

		if(Sdg.screen.camera.y < 0) 
			Sdg.screen.camera.y = 0; 
		else if(Sdg.screen.camera.y > Sdg.screen.camera.height + Sdg.gameHeight) 
			Sdg.screen.camera.y = Sdg.gameHeight - Sdg.screen.camera.width; 
	}
}