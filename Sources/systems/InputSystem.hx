package systems;
import actors.Actor;
import events.TargetEvent;
import sdg.event.EventObject;
import events.MoveEvent;
import screens.IGameState;
//import dashboard.Control;
import world.Node;
import components.AI;
import events.StopEvent;
import events.GetSpriteEvent;
import sdg.Object;
import Util;
import sdg.manager.Mouse;
import sdg.graphics.Sprite;
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
	}

	public function update()
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

	public function leftClick()
	{
		for(i in activeNodes)
		{
			if(Util.doesOverlapITwoD(selector, i) && 
			activeState.activeTeam.units.indexOf(i.occupant) != -1)
			{
				selectedActors.push(i.occupant);
			}
		}
		selector.visible = false;
	}

	public function rightClick()
	{
		if(selectedActors.length != 0)
		{
			for(i in activeNodes)
			{
				if(Mouse.x >= i.x && Mouse.x <= i.x + i.width && Mouse.y >= i.y && Mouse.y <= i.y + i.height)
				{
					selectedActors[0].eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(i, false));
				}
			}
		}
	}

	public function leftDown()
	{
		selectedActors = [];
		selector.visible = true;
		selector.x = Mouse.x;
		selector.y = Mouse.y;
		selector.width = 1;
		selector.height = 1;
		cast(selector.graphic, Polygon).points[1].x = Mouse.x+1;
		cast(selector.graphic, Polygon).points[1].y = Mouse.y;
		cast(selector.graphic, Polygon).points[2].x = Mouse.x+1;
		cast(selector.graphic, Polygon).points[2].y = Mouse.y+1;
		cast(selector.graphic, Polygon).points[3].x = Mouse.x;
		cast(selector.graphic, Polygon).points[3].y = Mouse.y+1;
	}

	public function rightDown()
	{
		
	}
}