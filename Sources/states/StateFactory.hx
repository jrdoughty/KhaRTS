package states;
import actors.Actor;


class StateFactory
{
	static var states:Map<String, Class<IState>> = ['idle'=>IdleState,'attack'=>AttackState,'move'=>MoveState];
	public static function create(name:String, a:Actor):IState
	{
		return cast Type.createInstance(Util.getOrInit(states,name,function(){return EmptyClassState;}),[a]);
	}
}