package states;
import actors.Actor;


class StateFactory
{
	static var states:Map<String, Class<IState>> = [
		'main_idle'=>IdleState,
		'main_wander'=>WanderState,
		'being_built'=>BeingBuiltState,
		'main_building_idle'=>BuildingIdleState,
		'producing'=>ProductionState,
		'builder'=>BuilderState,
		'gathering'=>GatherState,
		'returning'=>ReturnState,
		'attacking'=>AttackState,
		'moving'=>MoveState,
		'go_to_resource'=>GoToResourceState,
		'terminatah'=>Terminatah];
	public static function create(name:String, a:Actor):IState
	{
		return cast Type.createInstance(Util.getOrInit(states,name,function(){return EmptyClassState;}),[a]);
	}
}