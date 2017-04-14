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
	}

	public function update()
	{
		if(Mouse.isPressed(0))
		{
			leftClick();
		}
		if(Mouse.isPressed(1))
		{
			rightClick();
		}
	}

	public function leftClick()
	{
		selectedActors = [];
		for(i in activeNodes)
		{
			if(Mouse.x >= i.x && Mouse.x <= i.x + i.width && Mouse.y >= i.y && Mouse.y <= i.y + i.height && activeState.activeTeam.units.indexOf(i.occupant) != -1)
			{
				selectedActors.push(i.occupant);
			}
		}
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
}