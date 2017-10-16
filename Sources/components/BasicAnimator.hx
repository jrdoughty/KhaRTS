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
	public function new()
	{
		super();
	}

	public override function init()
	{
		super.init();
		var a = cast (object, Actor);
		regionList = a.data['rl'];
		a.eventDispatcher.addEvent(MoveAnimEvent.MOVE, moveAnim);
		a.eventDispatcher.addEvent(AnimateAttackEvent.ATTACK, attackAnim);
		a.eventDispatcher.addEvent(IdleAnimationEvent.IDLE, idleAnim);
		addAnimation("idle", [regionList[0]], 5);
		addAnimation("move", [regionList[0],regionList[1]], 5);
		addAnimation("attack", [regionList[2],regionList[0]], 5);
		play('idle', true);
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