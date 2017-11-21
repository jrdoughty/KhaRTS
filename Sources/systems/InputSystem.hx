package systems;
import actors.Actor;
import actors.ActorList;
import events.MoveEvent;
import screens.IGameScreen;
import world.Node;
import events.StopEvent;
import events.TargetEvent;
import sdg.Object;
import Util;
import sdg.manager.Mouse;
import sdg.manager.Keyboard;
import sdg.graphics.shapes.Polygon;
import sdg.Sdg;
import events.AttackInputEvent;
import events.MoveInputEvent;
import events.StopInputEvent;
import kha.input.KeyCode;

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
	BUILDING;
}

class InputSystem extends SimpleEventDispatcher
{
	public var ui:UI;

	private var inputState:InputState = InputState.SELECTING;
	private var relativeMouseX:Float;
	private var relativeMouseY:Float;
	private var activeScreen:IGameScreen;
	
	private var selectedActors:ActorList = new ActorList();
	private var activeNodes:Array<Node> = [];
	private var selector:Object;
	
	private var selectorStartX:Float;
	private var selectorStartY:Float;
	
	private var recentlyLeftClicked:Bool = false;
	private var clickTimerID:Int = -1;
	
	private var clickSprites: Array<Object> = [];
	
	
	public function new(state:IGameScreen) 
	{
		super();
		activeScreen = state;
		activeNodes = state.lvl.activeNodes;
		selector = new Object(0,0,Polygon.createRectangle(10,10,kha.Color.Green,true,.2));
		selector.graphic.alpha = .3;
		Sdg.screen.add(selector);
		selector.visible = false;
		ui = new UI();
		addEvent(AttackInputEvent.ATTACK, function(e){inputState = ATTACKING; selector.visible = false;});
		addEvent(MoveInputEvent.MOVE, function(e){inputState = MOVING; selector.visible = false;});
		addEvent(StopInputEvent.STOP, function(e){stopActors();});
	}

	private function stopActors()
	{
		inputState = SELECTING;
		for(i in selectedActors)
		{
			i.eventDispatcher.dispatchEvent(StopEvent.STOP, new StopEvent());
		}
		selector.visible = false;
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

		}
		else if(Mouse.x < 2 * unitWidth && Mouse.x > 0 )
		{
			delta = 9 - Math.floor(Mouse.x/moveCapAreaWidth * 10);
			if(delta > cam.x)
			{
				delta = cam.x;
			}
			cam.x -= delta;
			
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

		}
		else if(Mouse.y < 2 * unitHeight && Mouse.y > 0 )
		{
			delta = 9 - Math.floor(Mouse.y/moveCapAreaHeight * 10);
			if(delta > cam.y)
			{
				delta = cam.y;
			}
			cam.y -= delta;
			
		}
	}

	public function keyboardUpdate()
	{
		if(Keyboard.isPressed(KeyCode.M))
		{
			inputState = MOVING;
			selector.visible = false;
		}
		else if(Keyboard.isPressed(KeyCode.A))
		{
			inputState = ATTACKING;
			selector.visible = false;
		}
		else if(Keyboard.isPressed(KeyCode.S))
		{
			stopActors();
		}
	}

	public function leftClick()
	{
		var node:Node;
		var intersetingUIElements = [];
		for(i in ui.uiElements.objects)
		{
			if(i.x<= Mouse.x && Mouse.x <= i.x + i.width &&
			i.y <= Mouse.y && Mouse.y <= i.y + i.height)
			{
				intersetingUIElements.push(i); 
			}
		}
		if (intersetingUIElements.length != 0 && !selector.visible)
		{
			for(i in intersetingUIElements)
			{
				cast(i, UIElement).leftClick(Mouse.x, Mouse.y);
			}
		}
		else if(inputState == SELECTING)
		{
			var double = recentlyLeftClicked;
			recentlyLeftClicked = true;
			if(clickTimerID != -1)
			{
				Sdg.removeTimeTask(clickTimerID);
			}
			clickTimerID = Sdg.addTimeTask(function(){recentlyLeftClicked = false;trace('over');}, .3, 0, 1);
			
			selectedActors.list = [];
			for(i in activeNodes)
			{
				if(Util.doObjectandITwoDOverlap(selector, i) && 
				activeScreen.activeTeam.units.indexOf(i.occupant) != -1 &&
				selectedActors.indexOf(i.occupant) == -1)
				{
					selectedActors.push(i.occupant);
					if(double) break;//only need one for a double click
				}

				selectedActors.purgeBuildings();
			}
			if(double && selectedActors.list.length != 0)
			{
				for(i in selectedActors.list[0].team.units)
				{
					if(i.x + i.width >= Sdg.screen.camera.x && i.y + i.height >= Sdg.screen.camera.y &&
					i.x <= Sdg.screen.camera.x + Sdg.screen.camera.width && i.y <= Sdg.screen.camera.y + Sdg.screen.camera.height &&
					i.data['name'] == selectedActors.list[0].data['name'] && selectedActors.indexOf(i) == -1)
					{
						selectedActors.push(i);
					}
				}
			}
			ui.setUnits(selectedActors.list);
			selector.visible = false;
		}
		else if(inputState == MOVING)
		{

			node = activeNodes[Math.floor(relativeMouseX / activeScreen.lvl.tileset.tileWidth) + Math.floor(relativeMouseY / activeScreen.lvl.tileset.tileWidth)*activeScreen.lvl.levelWidth];
			selectedActors.moveTo(node);
			inputState = SELECTING;
		}
		else if(inputState == ATTACKING)
		{
			node = activeNodes[Math.floor(relativeMouseX / activeScreen.lvl.tileset.tileWidth) + Math.floor(relativeMouseY / activeScreen.lvl.tileset.tileWidth)*activeScreen.lvl.levelWidth];
			var j = 0;
			if(node.occupant == null)
			{
				selectedActors.moveTo(node, true);
			}
			else
			{
				selectedActors.target(node.occupant);
			}
			inputState = SELECTING;
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
		if(selectedActors.list.length != 0)
		{
			for(i in activeNodes)
			{
				if(relativeMouseX >= i.x && relativeMouseX <= i.x + i.width && relativeMouseY >= i.y && relativeMouseY <= i.y + i.height)
				{
					if(i.occupant != null && i.occupant.team != selectedActors.list[0].team && i.occupant.data['resource'] != null)
					{
						
						selectedActors.gather(i.occupant);
					}
					else if(i.occupant != null && i.occupant.team != selectedActors.list[0].team)
					{
						selectedActors.target(i.occupant);
					}
					else
					{
						selectedActors.moveTo(i);
					}
				}
			}
		}
	}
}