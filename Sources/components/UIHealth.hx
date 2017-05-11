package components;
import sdg.components.Component;

class UIHealth extends Component
{
	/**
	 * Int used to decide health using health as a percent of healthMax total
	 */
	public var healthMax:Int = 8;
	/**
	 * simple health bar sprite
	 */
	private var healthBar:Object;
	
	/**
	 * simple health bar fill sprite
	 */
	private var healthBarFill:Object;
	
	private var health:Float = 1;
	
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
		object.components.remove(this);
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
			if (health > 0)
			{
				p.points[1].x = 32*(health);
				p.points[2].x = 32*(health);
			}
			else
			{
				healthBarFill.visible = false;
			}
			healthBarFill.x = actor.x;
			healthBarFill.y = actor.y - 1;
			
		}
	}
	
	public function createSprite()
	{			
		healthBar = new Object(object.x, object.y, Polygon.createRectangle(32, 1, Color.Red, true));
		p = Polygon.createRectangle(32, 1, Color.Green,true);
		healthBarFill = new Object(object.x, object.y, p);
		sdg.Sdg.screen.add(healthBar);
		sdg.Sdg.screen.add(healthBarFill);
	}

	public override function destroy()
	{
		sdg.Sdg.screen.remove(healthBar);
		sdg.Sdg.screen.remove(healthBarFill);
	}
	
	public function kill(e:EventObject = null)
	{
		
		object.screen.remove(healthBar);
		object.screen.remove(healthBarFill);
		
		actor.kill();
		object.eventDispatcher.dispatchEvent(KillEvent.KILL, new KillEvent(actor));
		object.screen.remove(object, true);
	}
}