package components;
import events.ActionEvent;
import sdg.components.Component;
import events.ActionEvent;
/**
 * ...
 * @author John Doughty
 */
class AI extends Component
{	
	public function takeAction() 
	{
		object.eventDispatcher.dispatchEvent(ActionEvent.TAKE_ACTION, new ActionEvent());
	}
}