package components;

import sdg.components.Animator;
import sdg.atlas.Region;
import events.AnimateEvent;
import actors.Actor;

class DynamicAnimator extends Animator
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
		regionList = a.rl;
		a.eventDispatcher.addEvent(AnimateEvent.ANIMATE, anim);
		for(i in a.data.animations)
		{
			var frames:Array<Region> = [];
			var test:Array<Int> = [];
			for(j in i.frames)
			{
				frames.push(regionList[j.id]);
				test.push(j.id);
			}
			addAnimation(i.name, frames,i.fps);
		}
		play('idle', true);
	}

	public function anim(e:AnimateEvent)
	{
		play(e.anim, e.loop);
	}
}