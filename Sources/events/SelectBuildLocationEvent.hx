package events;
import sdg.event.EventObject;
import actors.Actor;
import systems.Data;
import systems.Data.BuildingsKind;
/**
 * ...
 * @author John Doughty
 */

class SelectBuildLocationEvent extends EventObject
{
	public var bData:Buildings;
	public var builder:Actor;
	public static inline var SELECT:String = "SELECT";


	public function new(builder:Actor, bName:String) 
	{
		super(true);
		this.builder = builder;
		bData = Data.buildings.get(cast (bName,BuildingsKind));
		//.dataMap['buildings'][bName];
	}
	
}