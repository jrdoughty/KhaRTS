package components;
import sdg.components.Component;
/**
 * ...
 * @author John Doughty
 */
class ComponentSystem
{
	
	private static var instance:ComponentSystem;
	public static var components:Array<Class<Component>> = [StateAI,
		Health,
		View,
		BasicAnimator,
		UIHealth];
	private var componentMap:Map<String, Class<Component>> = new Map();
	
	public function new() 
	{
		for (c in components)
		{
			var str = Type.getClassName(c).split(".")[1];
			componentMap.set(str, c);
		}
	}
	
	public static function getInstance()
	{
		if (instance == null)
		{
			instance = new ComponentSystem();
		}
		
		return instance;
	}
	
	public function getC(c:String)
	{
		if (componentMap.exists(c))
		{
			return cast (Type.createInstance(componentMap.get(c), []));
		}
		else
		{
			return new Component();
		}
	}
}