package components;
import sdg.components.Component;
import sdg.Object;
import sdg.graphics.shapes.Polygon;
import sdg.graphics.Sprite;
import actors.Actor;
import kha.Color;
import sdg.math.Vector2b;


typedef HealthData = {
	
	/**
	 * simple health bar sprite
	 */
	 public var healthBar:Object;
	
	 /**
	  * simple health bar fill sprite
	  */
	  public var healthBarFill:Object;
	 
	  public var actor:Actor;
	  public var p:Polygon;//shortcut
}

class UIHealth extends Component
{
	var data:HealthData = {
		healthBar: null,
		healthBarFill: null,
		actor: null,
		p:null
	}

	public function new(a:Actor) 
	{
		super();
		data.actor = a;
	}
	
	override public function init() 
	{
		super.init();
		if(!data.actor.data.exists('health'))
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
		
		if (data.healthBarFill != null)
		{
			if (data.actor.data['health'] > 0)
			{
				data.p.points[1].x = object.width*(data.actor.data['health']);
				data.p.points[2].x = object.width*(data.actor.data['health']);
			}
			else
			{
				data.healthBarFill.visible = false;
			}
			
		}
	}
	
	public function createSprite()
	{			
		data.healthBar = new Object(object.x, object.y, Polygon.createRectangle(object.width, 1, Color.Red, true));
		data.p = Polygon.createRectangle(object.width, 1, Color.Green,true);
		data.healthBarFill = new Object(object.x, object.y, data.p);
		sdg.Sdg.screen.add(data.healthBar);
		sdg.Sdg.screen.add(data.healthBarFill);
		data.healthBar.fixed = new Vector2b(true, true);
		data.healthBarFill.fixed = new Vector2b(true, true);
	}

	public override function destroy()
	{
		sdg.Sdg.screen.remove(data.healthBar);
		sdg.Sdg.screen.remove(data.healthBarFill);
	}
}