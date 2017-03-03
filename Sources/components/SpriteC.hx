package components;
import events.GetSpriteEvent;
import events.MoveToEvent;
import events.AnimateAttackEvent;
import events.MoveAnimEvent;
import events.IdleAnimationEvent;
import events.StopEvent;
import events.KillEvent;
import events.HideEvent;
import events.HurtEvent;
import events.RevealEvent;
import events.AddedSpriteEvent;
import adapters.TwoDSprite;

/**
 * ...
 * @author John Doughty
 */
class SpriteC extends Component
{
	var sprite:TwoDSprite;
	var idleFrame:Int;
	public function new(name:String) 
	{
		super(name);
	}
	
	override public function init() 
	{
		super.init();
		var assetPath:String;
		
		
		if (Reflect.hasField(entity.eData, "spriteFile") && entity.currentNodes.length > 0)
		{
			assetPath = "assets" + entity.eData.spriteFile.substr(2);
			if (Reflect.hasField(entity.eData, "speed"))
			{
				sprite = new TwoDSprite(entity.currentNodes[0].x, entity.currentNodes[0].y, assetPath, 8, 8, entity);
				sprite.addAnimation("active", [0, 1], 5, true);
				sprite.addAnimation("attack", [0, 2], 5, true);
				sprite.addAnimation("idle", [0], 5, true);
				entity.addEvent(IdleAnimationEvent.IDLE, idleAnim);
				entity.addEvent(AnimateAttackEvent.ATTACK, attackAnim);
				entity.addEvent(MoveToEvent.MOVE, moveTo);
				entity.addEvent(MoveAnimEvent.MOVE, activeAnim);
			}
			else 
			{
				sprite = new TwoDSprite(entity.currentNodes[0].x, entity.currentNodes[0].y, assetPath, entity);
			}
			entity.addEvent(RevealEvent.REVEAL, makeVisible);
			entity.addEvent(HideEvent.HIDE, killVisibility);
			entity.addEvent(KillEvent.KILL, kill);
			entity.addEvent(GetSpriteEvent.GET, getSprite);
			
			entity.dispatchEvent(AddedSpriteEvent.ADDED, new AddedSpriteEvent());
			
			//FlxG.state.add(sprite);
		}
		else
		{
			entity.removeC(name);
		}
	}	
	/**
	 * sets itself and the health bars to no longer be visible
	 */
	public function killVisibility(e:HideEvent)
	{
		sprite.setVisibility(false);
	}

	
	/**
	 * Sets itself and the health bars to be visible
	 */
	public function makeVisible(e:RevealEvent)
	{
		sprite.setVisibility(true);
	}
	
	public function kill(e:KillEvent)
	{
		sprite.kill();
	}
	
	public function attackAnim(e:AnimateAttackEvent)
	{
		sprite.playAnimation("attack");
	}
	
	public function activeAnim(e:MoveAnimEvent)
	{
		sprite.playAnimation("active");
	}
	
	public function idleAnim(e:IdleAnimationEvent)
	{
		sprite.playAnimation("idle");
	}
	
	public function moveTo(e:MoveToEvent)
	{
		sprite.x = e.x;
		sprite.y = e.y;
		entity.x = e.x;
		entity.y = e.y;
	}
	
	public function getSprite(e:GetSpriteEvent)
	{
		if (sprite != null)
		{
			e.callBackFunction(sprite);
		}
	}
}