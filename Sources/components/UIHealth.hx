package components;
import sdg.components.Component;
import sdg.Object;
import sdg.graphics.shapes.Polygon;
import actors.Actor;
import kha.Color;
import sdg.math.Vector2b;

class UIHealth extends Component
{
	/**
	 * simple health bar sprite
	 */
	private var healthBar:Object;
	
	/**
	 * simple health bar fill sprite
	 */
	private var healthBarFill:Object;
	
	private var actor:Actor;
	private var p:Polygon;//shortcut
	
	public function new(a:Actor) 
	{
		super();
		actor = a;
	}
	
	override public function init() 
	{
		super.init();
		if(!actor.data.exists('health'))
			object.components.remove(this);
		else
			createSprite();
	}
	
	/**
	 * maintains health bar fill size to match the actor
	 */
	public override function update()
	{
		super.update();
		
		if (healthBarFill != null)
		{
			if (actor.data['health'] > 0)
			{
				p.points[1].x = 32*(actor.data['health']);
				p.points[2].x = 32*(actor.data['health']);
			}
			else
			{
				healthBarFill.visible = false;
			}
			
		}
	}
	
	public function createSprite()
	{			
		healthBar = new Object(object.x, object.y, Polygon.createRectangle(32, 1, Color.Red, true));
		p = Polygon.createRectangle(32, 1, Color.Green,true);
		healthBarFill = new Object(object.x, object.y, p);
		sdg.Sdg.screen.add(healthBar);
		sdg.Sdg.screen.add(healthBarFill);
		healthBar.fixed = new Vector2b(true, true);
		healthBarFill.fixed = new Vector2b(true, true);
	}

	public override function destroy()
	{
		sdg.Sdg.screen.remove(healthBar);
		sdg.Sdg.screen.remove(healthBarFill);
	}
}