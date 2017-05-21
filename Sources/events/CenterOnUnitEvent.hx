package events;

import sdg.event.EventObject;
import actors.Actor;

class CenterOnUnitEvent extends EventObject
{
	public static var CENTER:String = 'CENTER_ON_UNIT';
	public var actor:Actor;
	public function new(actor:Actor)
	{
		this.actor = actor;
		super();
		bubble = true;
	}
}