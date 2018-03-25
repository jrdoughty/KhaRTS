package events;
import sdg.event.EventObject;
import actors.Actor;
import systems.Data;

/**
 * ...
 * @author John Doughty
 */

class SelectBuildLocationEvent extends EventObject
{
	public var bData:Map<String, Dynamic>;
	public var builder:Actor;
	public static inline var SELECT:String = "SELECT";


	public function new(builder:Actor, bName:String) 
	{
		super();
		this.builder = builder;
		bData = Data.dataMap['buildings'][bName];
		bubble = true;
	}
	
}