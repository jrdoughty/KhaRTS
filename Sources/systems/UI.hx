package systems;

import sdg.Object;
import sdg.graphics.Sprite;
import kha.Assets;
import sdg.Sdg;
import sdg.ObjectList;
import actors.Actor;
import systems.UIElement;
import events.KillEvent;
import systems.ActorRepresentative;
import events.CenterOnUnitEvent;

class UI extends SimpleEventDispatcher
{
	public var uiElements:ObjectList;
	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var dashboard:Object;
	private var units:Array<ActorRepresentative> = [];
	private var controls:Array<UIElement> = [];

	public function new()
	{
		super();
		uiElements = new ObjectList(0,0);
		dashboard = new Dashboard(0,592, new Sprite(Assets.images.dashui));
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
		units = [];
		for(i in 0...actors.length)
		{
			units.push(new ActorRepresentative((i * 32) % 128 + dashboard.x, Math.floor(i/4)*32 + dashboard.y, actors[i]));
			uiElements.add(units[i]);
			if(actors[i].data.exists('damage'))
			{
				controls.push(new UIElement(0,0,new sdg.graphics.Sprite(kha.Assets.images.controls)));
				controls[controls.length-1].leftClick = function(x:Float,y:Float){};
				uiElements.add(controls[controls.length-1]);
			}
			if(actors[i].data.exists('targetNode'))
			{
				//addMove
			}
			if(actors[i].data.exists('targetNode') || actors[i].data.exists('damage'))
			{
				//addStop
			}
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
				units[i].x = (i * 32) % 128 + dashboard.x;
				units[i].y = Math.floor(i/4)*32 + dashboard.y;
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