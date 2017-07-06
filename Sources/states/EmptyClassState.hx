package states;
import actors.Actor;

class EmptyClassState implements IState
{
	public function new(a:Actor)
	{
		trace('Non Existant State was called');
	}
	public function takeAction()
	{

	}
}