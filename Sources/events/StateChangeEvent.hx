package events;

import sdg.event.EventObject;
import actors.Actor;

class StateChangeEvent extends EventObject
{
	public static inline var CHANGE:String = 'CHANGE_STATE';
	public var state:String;
	/**
	 * Used in cases like idle to switch to a different state as soon as event fires
	 */
	public var immediate:Bool;

	public function new(s:String, now:Bool = false)
	{
		immediate = now;
		state = s;
		super();
	}
}