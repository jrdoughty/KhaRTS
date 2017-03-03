package components;
import actors.BaseActor;
import haxe.ds.StringMap;
import interfaces.IEntity;
import haxe.Timer;
/**
 * ...
 * @author John Doughty
 */
class Component
{
	public var name:String;
	public var entity:BaseActor;
	/**
	* base class for all components
	*/
	public function new(name:String) 
	{
		this.name = name;
	}
   
   
	public function attach(e:BaseActor)
	{
		entity = e;
		init();
	}
	
	/**
	 * decouples from entity
	 */
	public function detach()
	{
		entity = null;
	}
	
	/**
	 * if there is functionality that is data dependant on the entity being populated, 
	 * you'll use init to ensure you have that data first 
	 */
	public function init()
	{
	}
}