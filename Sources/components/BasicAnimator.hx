package components;

import sdg.components.Animator;
import sdg.atlas.Region;
import events.AnimateAttackEvent;
import events.IdleAnimationEvent;
import events.MoveAnimEvent;
import actors.Actor;

class BasicAnimator extends Animator
{
	var regionList:Array<Region>;
	public function new(rl:Array<Region>)
	{
		super();
		regionList = rl;
		
	}

	public override function init()
	{
		super.init();
		addAnimation("idle", [regionList[0]], 5);
		addAnimation("move", [regionList[0],regionList[1]], 5);
		addAnimation("attack", [regionList[2],regionList[0]], 5);
		play('idle', true);
		cast(object, Actor).eventDispatcher.addEvent(MoveAnimEvent.MOVE, moveAnim);
		cast(object, Actor).eventDispatcher.addEvent(AnimateAttackEvent.ATTACK, attackAnim);
		cast(object, Actor).eventDispatcher.addEvent(IdleAnimationEvent.IDLE, idleAnim);
	}

	public function moveAnim(e:MoveAnimEvent)
	{
		play('move', true);
	}

	public function attackAnim(e:AnimateAttackEvent)
	{
		play('attack', false);
	}

	public function idleAnim(e:IdleAnimationEvent)
	{
		play('idle', true);
	}
}