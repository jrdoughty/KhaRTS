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
		regionList = a.data['rl'];
		a.eventDispatcher.addEvent(AnimateEvent.ANIMATE, anim);
		var animList: Array<Dynamic> = a.data['animations'];
		for(i in animList)
		{
			var frames:Array<Region> = [];
			var listFrames:Array<Dynamic> = i.frames;
			var test:Array<Int> = [];
			for(j in listFrames)
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