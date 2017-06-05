package systems;

import sdg.Object;
import sdg.graphics.Sprite;
import kha.Assets;
import sdg.Sdg;
import sdg.ObjectList;
import actors.Actor;
import systems.UIElement;
import sdg.event.IEventDispatcher;
import events.KillEvent;
import haxe.Constraints.Function;
import sdg.event.EventSystem;
import sdg.event.EventObject;
import systems.ActorRepresentative;
import events.CenterOnUnitEvent;

class UI implements IEventDispatcher
{
	public var uiElements:ObjectList;
	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var listeners:Map<String, Array<Function>> = new Map();
	private var dashboard:Object;
	private var units:Array<ActorRepresentative> = [];

	public function new()
	{
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
	
	/**
	 * Adds Event Listener for the name string and addes the callback to the functions to be 
	 * run when that event is fired off
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be added to array of callbacks upon event dispatch
	 */
	public function addEvent(name:String, callback:Function)
	{
		if (!listeners.exists(name))
		{
			listeners.set(name, [callback]);
			EventSystem.get().addEvent(name,this);
		}
		else if (listeners[name].indexOf(callback) == -1)
		{
			listeners[name].push(callback);
			EventSystem.get().addEvent(name,this);
		}
	}
	
	/**
	 * Removes Event Listener for the strings/callback combination
	 * 
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be removed from event
	 */
	public function removeEvent(name:String, callback:Function)
	{
		var i:Int;
		if (listeners.exists(name) && listeners[name].indexOf(callback) != -1)
		{
			for (i in 0...listeners[name].length)
			{
				if (listeners[name][i] == callback)
				{
					listeners[name].splice(i, 1);
					EventSystem.get().removeEvent(name,this);
					break;
				}
			}
		}
	}
	
	/**
	 * Triggers event using the name string. 
	 * The eventObject is passed to all callback functions listening to the event
	 * @param	name		Event to Trigger
	 * @param	eventObject	data the Event's callback functions need, creates a blank EventObject if left null
	 */
	public function dispatchEvent(name:String, eventObject:EventObject = null)
	{
		if (eventObject == null)
		{
			eventObject = new EventObject();
		}
		if (listeners.exists(name) && !eventObject.bubble)
		{
			for (func in listeners[name])
			{
				func(eventObject);
			}
		}
		if(eventObject.bubble)
		{
			EventSystem.get().dispatch(name, eventObject);
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