package components;

import sdg.components.Component;
import actors.Actor;

class ActorComponent extends Component
{
	private var actor:Actor;
	public override function init()
	{
		super.init();
		if(Type.getClass(object) == Actor)
			actor = cast(object, Actor);
		else
			destroy();
	}
}