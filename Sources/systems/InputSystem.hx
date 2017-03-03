package systems;
import actors.BaseActor;
import actors.DBActor;
import actors.Building;
import events.TargetEvent;
import events.EventObject;
import events.MoveEvent;
import interfaces.IGameState;
import dashboard.Control;
import world.Node;
import components.AI;
import events.StopEvent;
import events.GetSpriteEvent;
import adapters.TwoDSprite;
import adapters.TwoDRect;
import Util;

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
	
	private var selectedActors:Array<BaseActor> = [];
	private var selectedBuildings:Array<Building> = [];
	private var activeNodes:Array<TwoDSprite> = [];
	private var nodes:Array<Node>;
	private var selector:TwoDSprite;
	
	private var selectorStartX:Float;
	private var selectorStartY:Float;
	
	private var newLeftClick:Bool = true;
	private var wasRightMouseDown:Bool = false;
	private var wasLeftMouseDown:Bool = false;
	
	private var clickSprites: Array<TwoDSprite> = [];
	
	
	public function new(state:IGameState) 
	{
		activeState = state;
		for (i in 0...Node.activeNodes.length)
		{
			activeNodes.push(Node.activeNodes[i]);
			//FlxMouseEventManager.add(Node.activeNodes[i], null, null, onOver);
		}
	}
	
	private function onOver(sprite:Node):Void
	{
		if (inputState == SELECTING)
		{
			if (activeState.getLevel().highlight != null && sprite.occupant != null)
			{
				activeState.getLevel().highlight.setVisibility(true);
				activeState.getLevel().highlight.x = sprite.x;
				activeState.getLevel().highlight.y = sprite.y;
			}
			else
			{
				activeState.getLevel().highlight.setVisibility(false);
			}
		}
		else if (inputState == MOVING || inputState == ATTACKING)
		{
			activeState.getLevel().highlight.setVisibility(true);
			activeState.getLevel().highlight.x = sprite.x;
			activeState.getLevel().highlight.y = sprite.y;
		}
	}
	
	
	public function setupClickControls(controls:Array<Control>)
	{
		var i:Int;
		for (i in 0...controls.length)
		{
			if (controls[i].callbackFunction != null)
			{
				var func:Dynamic = controls[i].callbackFunction;
				//FlxMouseEventManager.add(controls[i], null, controls[i].useCallback, controls[i].hover, controls[i].out, false, true, false);
				
			}
			else if (controls[i].type == ActorControlTypes.MOVE)
			{
				//FlxMouseEventManager.add(controls[i], null, move, controls[i].hover, controls[i].out, false, true, false);
			}
			else if (controls[i].type == ActorControlTypes.ATTACK)
			{
				//FlxMouseEventManager.add(controls[i], null, attack, controls[i].hover, controls[i].out, false, true, false);
			}
			else if (controls[i].type == ActorControlTypes.STOP)
			{
				//FlxMouseEventManager.add(controls[i], null, stop, controls[i].hover, controls[i].out, false, true, false);
			}
			
		}
	}
	
	private function move(sprite:TwoDSprite = null)
	{
		inputState = MOVING;
	}
	
	private function attack(sprite:TwoDSprite = null)
	{
		inputState = ATTACKING;
	}
	
	public function update()
	{
		//cameraUpdate();
		/*
		if (FlxG.keys.pressed.M)
		{
			move();
		}
		else if (FlxG.keys.pressed.S)
		{
			stop();
		}
		else if (FlxG.keys.pressed.A)
		{
			attack();
		}
		
		if (FlxG.mouse.pressed && wasLeftMouseDown)
		{
			setupSelectorSize();
			wasLeftMouseDown = true;
		}
		else if (FlxG.mouse.pressed && wasLeftMouseDown == false)
		{
			selector = new TwoDRect();
			if (inputState == SELECTING)
			{
				selector.setAlpha(.5);
			}
			else
			{
				selector.setAlpha(0);
			}
			selectorStartX = FlxG.mouse.x;
			selectorStartY = FlxG.mouse.y;
			selector.x = selectorStartX;
			selector.y = selectorStartY;
			selector.setImageSize(1, 1);
			wasLeftMouseDown = true;
		} 
		else if (wasLeftMouseDown && FlxG.mouse.pressed == false)
		{
			click();
			wasLeftMouseDown = false;
		}
		
		if (FlxG.mouse.justPressedRight)
		{
			rightClick();
		}
		*/
	}
	
	private function setupSelectorSize()
	{
		var width:Int;
		var height:Int;
		
		if (inputState == SELECTING)
		{
			/*
			if (FlxG.mouse.x < selectorStartX)
			{
				selector.x = FlxG.mouse.x;
				width = Math.round(selectorStartX - FlxG.mouse.x);
			}
			else
			{
				selector.x = selectorStartX;
				width = Math.round(FlxG.mouse.x - selector.x);
			}
			
			if (FlxG.mouse.y < selectorStartY)
			{
				selector.y = FlxG.mouse.y;
				height = Math.round(selectorStartY - FlxG.mouse.y);
			}
			else
			{
				selector.y = selectorStartY;
				if (FlxG.mouse.y > activeState.dashboard.background.y)
				{
					height = Math.round(activeState.dashboard.background.y - selector.y);
				}
				else
				{
					height = Math.round(FlxG.mouse.y - selector.y);
				}
			}
			if (width == 0)
			{
				width = 1;//setGraphics makes squares with a 0 height or width
			}
			if (height == 0)
			{
				height = 1;//setGraphics makes squares with a 0 height or width
			}
			*/
		}
		else 
		{
				selector.setAlpha(.5);
			width = 1;
			height = 1;
			//selector.x = FlxG.mouse.x;
			//selector.y = FlxG.mouse.y;
		}
		selector.setImageSize(width, height);
	}
	
	private function addDBActorSprite(s:TwoDSprite)
	{
		clickSprites.push(s);
	}
	
	
	private function click():Void
	{
		
		newLeftClick = true;
		if (Util.groupOverlap([selector], [activeState.dashboard.background]).group1.length == 0)
		{
			if (inputState == SELECTING)
			{
				findAndSelectOverlapingActors();
			}
			else if (inputState == MOVING)
			{			
				if (selector.width < activeState.getLevel().tiledLevel.tilewidth && selector.height < activeState.getLevel().tiledLevel.tileheight)
				{
					Util.emulateFlxGOverlap([selector], activeNodes, moveToNode);
				}
			}
			else if (inputState == ATTACKING)
			{			
				if (selector.width < activeState.getLevel().tiledLevel.tilewidth && selector.height < activeState.getLevel().tiledLevel.tileheight)
				{
					Util.emulateFlxGOverlap([selector], activeNodes, attackClick);
				}
			}
			resetInputState();
			
		}
		//FlxG.state.remove(selector);
		selector = null;
		
	}
	
	private function findAndSelectOverlapingActors()
	{
		var i:Int;
		var overlaps:OverlappingObjects = null;
		clickSprites = [];
				
		for (i in 0...activeState.activeTeam.units.length )
		{
			activeState.activeTeam.units[i].dispatchEvent(GetSpriteEvent.GET, new GetSpriteEvent(addDBActorSprite));
		}
		if (clickSprites.length > 0)
		{
			overlaps = Util.groupOverlap([selector], clickSprites);
		}
		if (overlaps.group1.length == 0 || overlaps == null)//If no units overlapped, we're going to check for buildings
		{
			clickSprites = [];
			
			for (building in activeState.activeTeam.buildings )
			{
				building.dispatchEvent(GetSpriteEvent.GET, new GetSpriteEvent(addDBActorSprite));
			}
			
			overlaps = Util.groupOverlap([selector], clickSprites);
		}
		if (overlaps.group1.length == 0)
			{
				activeState.dashboard.clearDashBoard();//Select Enemies later
			}
			else
			{
				for (i in 0...overlaps.group1.length)
				{
					selectOverlapActors(selector, overlaps.group2[i]);
				}
			}
	}
	
	private function rightClick()
	{
		if (selector == null)
		{
			selector = new TwoDRect(FlxG.mouse.x, FlxG.mouse.y);
			//FlxG.state.add(selector);
		}
		selector.setAlpha(.5);
		if (Util.groupOverlap([selector], [activeState.dashboard.background]).group1.length == 0)
		{
			if (selector.width < activeState.getLevel().tiledLevel.tilewidth && selector.height < activeState.getLevel().tiledLevel.tileheight)
			{
				Util.emulateFlxGOverlap([selector], activeNodes, attackClick);
			}
		}
		//FlxG.state.remove(selector);
		selector = null;
	}
	
	private function stop(sprite:TwoDSprite = null)
	{
		var i:Int;
		for (i in 0...selectedActors.length)
		{
			selectedActors[i].dispatchEvent(StopEvent.STOP);
		}
		resetInputState();
	}
	
	public function resetInputState()
	{
		inputState = SELECTING;
	}
	
	private function moveToNode(selector:TwoDSprite,node:Node):Void
	{
		var i:Int;
		if (selectedActors.length > 0 && node.isPassible() && (node.occupant == null || activeState.activeTeam.isThreat(node.occupant.team.id)))
		{
			for (i in 0...selectedActors.length)
			{
				selectedActors[i].dispatchEvent(MoveEvent.MOVE, new MoveEvent(node));
			}
		}
	}
	
	private function attackClick(selector:TwoDSprite,node:Node):Void
	{
		var i:Int;
		if (selectedActors.length > 0 && node.isPassible() && node.occupant == null)
		{
			for (i in 0...selectedActors.length)
			{
				selectedActors[i].dispatchEvent(MoveEvent.MOVE, new MoveEvent(node, true));
			}
		}
		else if (node.occupant != null && activeState.activeTeam.isThreat(node.occupant.team.id))
		{
			for (i in 0...selectedActors.length)
			{
				selectedActors[i].dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(node.occupant));
			}
		}
	}
	
	private function attackOverlap(selector:TwoDSprite, unit:BaseActor):Void
	{
		var i:Int;
		for (i in 0...selectedActors.length)
		{
			selectedActors[i].dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(unit));
		}
	}
	
	private function clearSelected()
	{
		var i:Int;
		for (i in 0...selectedActors.length)
		{
			selectedActors[i].resetSelect();
		}
		selectedActors = [];
		selectedBuildings = [];
		activeState.dashboard.clearDashBoard();
	}
	
	private function selectOverlapActors(selector:TwoDSprite, unit:TwoDSprite):Void
	{
		if (newLeftClick)
		{
			clearSelected();
			activeState.dashboard.setSelected(unit.entity);
		}
		activeState.dashboard.addSelectedActor(unit.entity);
		selectedActors.push(unit.entity);
		unit.entity.select();
		newLeftClick = false;
	}
}