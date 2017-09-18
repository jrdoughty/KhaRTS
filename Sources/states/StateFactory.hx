package states;
import actors.Actor;


class StateFactory
{
	static var states:Map<String, Class<IState>> = ['main_idle'=>IdleState,'main_wander'=>WanderState,'attacking'=>AttackState,'moving'=>MoveState];
	public static function create(name:String, a:Actor):IState
	{
		return cast Type.createInstance(Util.getOrInit(states,name,function(){trace(name);return EmptyClassState;}),[a]);
	}
}