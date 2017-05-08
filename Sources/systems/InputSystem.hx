package systems;
import actors.Actor;
import events.MoveEvent;
import screens.IGameState;
import world.Node;
import events.StopEvent;
import events.TargetEvent;
import sdg.Object;
import Util;
import sdg.manager.Mouse;
import sdg.manager.Keyboard;
import sdg.graphics.shapes.Polygon;
/**
 * ...
 * @author ...
 */

enum InputState 
{
	SELECTING;
	ATTACKING;
	MOVING;
	CASTING;
}
 
class InputSystem
{
	private var inputState:InputState = InputState.SELECTING;
	private var activeState:IGameState;
	private var ui:UI;
	
	private var selectedActors:Array<Actor> = [];
	private var activeNodes:Array<Node> = [];
	private var selector:Object;
	
	private var selectorStartX:Float;
	private var selectorStartY:Float;
	
	private var newLeftClick:Bool = true;
	private var wasRightMouseDown:Bool = false;
	private var wasLeftMouseDown:Bool = false;
	
	private var clickSprites: Array<Object> = [];
	
	
	public function new(state:IGameState) 
	{
		activeState = state;
		activeNodes = state.lvl.activeNodes;
		selector = new Object(0,0,Polygon.createRectangle(10,10,kha.Color.Green,true,.2));
		selector.graphic.alpha = .3;
		sdg.Sdg.screen.add(selector);
		selector.visible = false;
		ui = new UI();
	}

	public function update()
	{
		mouseUpdate();
		keyboardUpdate();
	}

	public function mouseUpdate()
	{
		if(Mouse.isPressed(0))
		{
			leftDown();
		}
		if(Mouse.isPressed(1))
		{
			rightDown();
		}
		if(Mouse.isUp(0))
		{
			leftClick();
		}
		if(Mouse.isUp(1))
		{
			rightClick();
		}
		if(Mouse.isHeld(0) && selector.visible == true)
		{
			selector.width = Std.int(Mouse.x - selector.x);
			selector.height = Std.int(Mouse.y - selector.y);

			cast(selector.graphic, Polygon).points[1].x = Mouse.x - selector.x;
			cast(selector.graphic, Polygon).points[1].y = 0;
			cast(selector.graphic, Polygon).points[2].x = Mouse.x - selector.x;
			cast(selector.graphic, Polygon).points[2].y = Mouse.y - selector.y;
			cast(selector.graphic, Polygon).points[3].x = 0;
			cast(selector.graphic, Polygon).points[3].y = Mouse.y - selector.y;
		}
	}

	public function keyboardUpdate()
	{
		if(Keyboard.isPressed('m'))
		{
			inputState = MOVING;
			selector.visible = false;
		}
		else if(Keyboard.isPressed('a'))
		{
			inputState = ATTACKING;
			selector.visible = false;
		}
		else if(Keyboard.isPressed('s'))
		{
			inputState = SELECTING;
			for(i in selectedActors)
			{
				i.eventDispatcher.dispatchEvent(StopEvent.STOP, new StopEvent());
			}
			selector.visible = false;
		}
	}

	public function leftClick()
	{
		var node:Node;
		if(inputState == SELECTING)
		{
			selectedActors = [];
			for(i in activeNodes)
			{
				if(Util.doObjectandITwoDOverlap(selector, i) && 
				activeState.activeTeam.units.indexOf(i.occupant) != -1)
				{
					selectedActors.push(i.occupant);
				}
			}
			ui.setUnits(selectedActors);
			selector.visible = false;
		}
		if(inputState == MOVING)
		{

			node = activeNodes[Math.floor(Mouse.x / activeState.lvl.tileset.tileWidth) + Math.floor(Mouse.y / activeState.lvl.tileset.tileWidth)*activeState.lvl.levelWidth];
			for(i in selectedActors) i.eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(node, false));
			inputState = SELECTING;
		}
		if(inputState == ATTACKING)
		{
			node = activeNodes[Math.floor(Mouse.x / activeState.lvl.tileset.tileWidth) + Math.floor(Mouse.y / activeState.lvl.tileset.tileWidth)*activeState.lvl.levelWidth];
			for(i in selectedActors) 
			{
				if(node.occupant == null)
				{
					i.eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(node, true));
				}
				else
				{
					i.eventDispatcher.dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(node.occupant));
				}
				inputState = SELECTING;
			}
		}
	}

	public function rightClick()
	{
		inputState = SELECTING;
	}

	public function leftDown()
	{		
		var intersetingUIElements = [];
		for(i in ui.uiElements.objects)
		{
			if(i.x<= Mouse.x && Mouse.x <= i.x + i.width &&
			i.y <= Mouse.y && Mouse.y <= i.y + i.height)
			{
				intersetingUIElements.push(i);
			}
		}
		if (intersetingUIElements.length != 0)
		{
			for(i in intersetingUIElements)
			{
				cast(i, UIElement).leftDown(Mouse.x, Mouse.y);
			}
		}
		else if(inputState == SELECTING)
		{
			selector.visible = true;
			selector.x = Mouse.x;
			selector.y = Mouse.y;
			selector.width = 1;
			selector.height = 1;
			var p = cast(selector.graphic, Polygon);
			p.points[1].x = Mouse.x+1;
			p.points[1].y = Mouse.y;
			p.points[2].x = Mouse.x+1;
			p.points[2].y = Mouse.y+1;
			p.points[3].x = Mouse.x;
			p.points[3].y = Mouse.y+1;
		}
	}

	public function rightDown()
	{
		if(selectedActors.length != 0)
		{
			for(i in activeNodes)
			{
				if(Mouse.x >= i.x && Mouse.x <= i.x + i.width && Mouse.y >= i.y && Mouse.y <= i.y + i.height)
				{
					for(j in selectedActors) 
					{
						if(i.occupant != null && i.occupant.team != j.team)
							j.eventDispatcher.dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(i.occupant));
						else
							j.eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(i, false));
					}
				}
			}
		}
	}
}