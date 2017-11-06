package states;

interface IState
{
	public function takeAction():Void;
	public function enter():Void;
	public function exit():Void;
}