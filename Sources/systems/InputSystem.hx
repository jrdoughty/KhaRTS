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
import sdg.Sdg;
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
	public var ui:UI;

	private var inputState:InputState = InputState.SELECTING;
	private var relativeMouseX:Float;
	private var relativeMouseY:Float;
	private var activeState:IGameState;
	
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
		Sdg.screen.add(selector);
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
		relativeMouseX = Sdg.screen.camera.x + Mouse.x;
		relativeMouseY = Sdg.screen.camera.y + Mouse.y;
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
			selector.width = Std.int(relativeMouseX - selector.x);
			selector.height = Std.int(relativeMouseY - selector.y);
			
			var p = cast(selector.graphic, Polygon);

			p.points[1].x = relativeMouseX - selector.x;
			p.points[1].y = 0;
			p.points[2].x = relativeMouseX - selector.x;
			p.points[2].y = relativeMouseY - selector.y;
			p.points[3].x = 0;
			p.points[3].y = relativeMouseY - selector.y;
		}

		updateCam();
	}

	public function updateCam()
	{
		var cam = Sdg.screen.camera;
		var delta:Float;

		var unitWidth = cam.width/100;
		var moveCapAreaWidth = (cam.width - (unitWidth * 89));
		if(Mouse.x > 97 * unitWidth)
		{
			var mousePosInArea = Mouse.x - unitWidth * 89;
			delta = Math.floor(mousePosInArea/moveCapAreaWidth * 10);
			if(delta + cam.x + cam.width > Sdg.screen.worldWidth)
			{
				delta = Sdg.screen.worldWidth - (cam.x + cam.width);
			}
			cam.x += delta;
			ui.uiElements.apply(function(o:Object){o.x += delta;});

		}
		else if(Mouse.x < 2 * unitWidth && Mouse.x > 0 )
		{
			delta = 9 - Math.floor(Mouse.x/moveCapAreaWidth * 10);
			if(delta > cam.x)
			{
				delta = cam.x;
			}
			cam.x -= delta;
			ui.uiElements.apply(function(o:Object){o.x -= delta;});
			
		}

		var unitHeight = cam.height/100;
		var moveCapAreaHeight = (cam.height - (unitHeight * 89));
		if(Mouse.y > 97 * unitHeight)
		{
			var mousePosInArea = Mouse.y - unitHeight * 89;
			delta = Math.floor(mousePosInArea/moveCapAreaHeight * 10);
			if(delta + cam.y + cam.height > Sdg.screen.worldHeight)
			{
				delta = Sdg.screen.worldHeight - (cam.y + cam.height);
			}
			cam.y += delta;
			ui.uiElements.apply(function(o:Object){o.y += delta;});

		}
		else if(Mouse.y < 2 * unitHeight && Mouse.y > 0 )
		{
			delta = 9 - Math.floor(Mouse.y/moveCapAreaHeight * 10);
			if(delta > cam.y)
			{
				delta = cam.y;
			}
			cam.y -= delta;
			ui.uiElements.apply(function(o:Object){o.y -= delta;});
			
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
		var intersetingUIElements = [];
		for(i in ui.uiElements.objects)
		{
			if(i.x<= relativeMouseX && relativeMouseX <= i.x + i.width &&
			i.y <= relativeMouseY && relativeMouseY <= i.y + i.height)
			{
				intersetingUIElements.push(i);
			}
		}
		if (intersetingUIElements.length != 0)
		{
			for(i in intersetingUIElements)
			{
				cast(i, UIElement).leftClick(relativeMouseX, relativeMouseY);
			}
		}
		else if(inputState == SELECTING)
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
		else if(inputState == MOVING)
		{

			node = activeNodes[Math.floor(relativeMouseX / activeState.lvl.tileset.tileWidth) + Math.floor(relativeMouseY / activeState.lvl.tileset.tileWidth)*activeState.lvl.levelWidth];
			for(i in selectedActors) i.eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(node, false));
			inputState = SELECTING;
		}
		else if(inputState == ATTACKING)
		{
			node = activeNodes[Math.floor(relativeMouseX / activeState.lvl.tileset.tileWidth) + Math.floor(relativeMouseY / activeState.lvl.tileset.tileWidth)*activeState.lvl.levelWidth];
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
			if(i.x<= relativeMouseX && relativeMouseX <= i.x + i.width &&
			i.y <= relativeMouseY && relativeMouseY <= i.y + i.height)
			{
				intersetingUIElements.push(i);
			}
		}
		if (intersetingUIElements.length != 0)
		{
			for(i in intersetingUIElements)
			{
				cast(i, UIElement).leftDown(relativeMouseX, relativeMouseY);
			}
		}
		else if(inputState == SELECTING)
		{
			selector.visible = true;
			selector.x = relativeMouseX;
			selector.y = relativeMouseY;
			selector.width = 1;
			selector.height = 1;

			var p = cast(selector.graphic, Polygon);
			
			p.points[1].x = relativeMouseX+1;
			p.points[1].y = relativeMouseY;
			p.points[2].x = relativeMouseX+1;
			p.points[2].y = relativeMouseY+1;
			p.points[3].x = relativeMouseX;
			p.points[3].y = relativeMouseY+1;
		}
	}

	public function rightDown()
	{
		if(selectedActors.length != 0)
		{
			for(i in activeNodes)
			{
				if(relativeMouseX >= i.x && relativeMouseX <= i.x + i.width && relativeMouseY >= i.y && relativeMouseY <= i.y + i.height)
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