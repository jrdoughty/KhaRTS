package components;

import sdg.components.Animator;
import sdg.atlas.Region;
import events.QueueEvent;
import events.IdleAnimationEvent;
import events.BuildEvent;
import actors.Actor;

class BuildingAnimator extends Animator
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
		a.eventDispatcher.addEvent(QueueEvent.QUEUE, produceAnim);
		a.eventDispatcher.addEvent(BuildEvent.BUILD, buildAnim);
		a.eventDispatcher.addEvent(IdleAnimationEvent.IDLE, idleAnim);
		addAnimation("idle", [regionList[0]], 5);
		addAnimation("producing", [regionList[2]], 5);
		addAnimation("building", [regionList[1]], 5);
		play('idle', true);
	}
	
	public function buildAnim(e:BuildEvent)
	{
		play('building', true);
	}
	
	public function produceAnim(e:QueueEvent)
	{
		play('producing', false);
	}

	public function idleAnim(e:IdleAnimationEvent)
	{
		play('idle', true);
	}
}