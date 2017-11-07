package states;
import actors.Actor;
import events.StateChangeEvent;
import events.AnimateAttackEvent;
import events.HurtEvent;
import events.MoveAnimEvent;
import events.IdleAnimationEvent;
import world.Node;
import systems.AStar;
import tween.Delta;
import events.StopEvent;
import events.TargetEvent;

typedef AttackData = {
	var name : String;
	var damage : Int;
	var minRange : Int; 
	var maxRange : Int; 
	var coolDown : Int;
}


class AttackState extends MovingState
{

	/**
	* Actors attacks
	*/
	private var attacks:Array<AttackData>;

	public function new(a:Actor)
	{
		super(a);
		
		attacks = a.data.get('attacks');
		if(attacks != null && attacks.length > 0)
			a.eventDispatcher.addEvent(TargetEvent.ATTACK_ACTOR, TargetActor);
		else
			trace('attacking unit created without an attack');
		a.eventDispatcher.addEvent(StopEvent.STOP, resetData);
	}

	public override function enter()
	{
		super.enter();
		if (actor.data['targetEnemy'] != null && actor.data['targetEnemy'].alive )
		{
			if(isEnemyInRange())
				true;
			else
				actor.coolDown = Std.int(actor.data['moveCooldown']);
		}
		else
		{
			actor.coolDown = Std.int(actor.data['moveCooldown']);
		}
	}

	public override function takeAction()
	{
		super.takeAction();
		var i:Int;
		
		if (actor.data['targetEnemy'] != null && actor.data['targetEnemy'].alive)
		{
			var attack = getAvailableAttack();
			if (attack != null)
			{
				
				hit(attack);
			}
			else if(actor.data['mobile'])
			{
				chase();
			}
		}
		else
		{
			if(actor.data['targetEnemy'] != null && !actor.data['targetEnemy'].alive)
				actor.data['targetEnemy'] = null;
			actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('idle', true));
		}
	}
	
	/**
	 * checks to see if the enemy is next to the Unit, will need changed for reach
	 * @return whether the enemy is in Range
	 */
	private function isEnemyInRange():Bool
	{
		return getAvailableAttack() != null;
	}
	
	/**
	 * checks to see if the enemy is within range of one of the actors attacks and returns the attack
	 * @return whether the enemy is in Range
	 */
	private function getAvailableAttack():AttackData
	{
		var inRange:Bool = false;
		var x1:Int;
		var x2:Int;
		var y1:Int;
		var y2:Int;
		var dist:Float;
		
		if(actor.data['targetEnemy'] != null)
		{
			var a:Actor = actor.data['targetEnemy'];
			for(i in attacks)
			{
				x1 = actor.currentNodes[0].nodeX;
				x2 = a.currentNodes[0].nodeX;
				y1 = actor.currentNodes[0].nodeY;
				y2 = a.currentNodes[0].nodeY;
				dist = Math.sqrt(Math.abs(x1 - x2) + Math.abs(y1 - y2));
				
				if(dist > i.minRange && dist < (i.maxRange==1?i.maxRange*1.42:i.maxRange))
				{
					return i;
				}
			}
		}
		return null;
	}
		
	/**
	 * damages enemy base on object.damage and targetEnemy.healthMax
	 */
	private function hit(attack:AttackData)
	{
		var ed = actor.data['targetEnemy'].eventDispatcher;//hack to deal with js error, js gets confusted as to what 'this' should be
		ed.dispatchEvent(HurtEvent.HURT, new HurtEvent(attack.damage));
		actor.eventDispatcher.dispatchEvent(AnimateAttackEvent.ATTACK, new AnimateAttackEvent());
		actor.coolDown = attack.coolDown;
		if (actor.data['targetEnemy'].alive == false)
		{
			actor.data['targetEnemy'] = null;
		}
	}

	/**
	 * similar to move function except more complicated, as it needs to determine if the 
	 * targetEnemy has moved and adjust if it has. May merge with Move Eventually
	 */
	private function chase()
	{		
		if (path.length == 0 || path[path.length - 1] != actor.data['targetEnemy'].currentNodes[0])
		{
			path = AStar.newPath(actor.currentNodes[0], actor.data['targetEnemy'].currentNodes[0]);
		}
		
		
		if (path.length > 1 && path[1].occupant == null)
		{
			moveAlongPath();
		}
		else
		{
			if(actor.data['targetNode'] == null && actor.data['targetEnemy'] != null)
			{
				actor.data['targetNode'] = cast(actor.data['targetEnemy'], Actor).currentNodes[0];
			}
			newPath();
		}
		if (failedToMove)
		{
			actor.eventDispatcher.dispatchEvent(IdleAnimationEvent.IDLE, new IdleAnimationEvent());
		}
		else
		{
			actor.eventDispatcher.dispatchEvent(MoveAnimEvent.MOVE, new MoveAnimEvent());
		}
	}
	
	/**
	 * sets target to start either attack or chase sequence
	 * @param	aEvent 	holds target Actor, may need qualifier eventually
	 */
	public function TargetActor(aEvent:TargetEvent)
	{
		actor.eventDispatcher.dispatchEvent(StopEvent.STOP, new StopEvent());
		actor.data['targetEnemy'] = aEvent.target;
		actor.eventDispatcher.dispatchEvent(StateChangeEvent.CHANGE, new StateChangeEvent('attacking'));
	}
	
	
	/**
	 * resets all the decision making vars to null or false
	 * 
	 * @param	eO		EventObject is required for listenerCallbacks
	 */
	public function resetData(eO:StopEvent = null):Void 
	{
		actor.data.set('targetEnemy', null);
		actor.data.set('aggressive', false);
	}

	/**
	 * checks to see which enemy is next to the Unit, will need changed for reach
	 * @return the enemy that is above, below, or to the side
	 */
	private function getEnemyInRange():Actor
	{
		var result:Actor = null;
		var i:Int;
		var a:Actor = actor.data['targetEnemy'];
		var x:Int = actor.currentNodes[0].nodeX;
		var y:Int = actor.currentNodes[0].nodeY;
		var scrn = cast(actor.screen, screens.IGameScreen);

		for(attack in attacks)//modified from https://stackoverflow.com/questions/2435963/radial-grid-search-algorithm
		{
			for(range in attack.minRange...attack.maxRange + 1)
			{
				var minX = x - range > 0 ? x - range : 0; 
				var maxX = x + range < scrn.lvl.levelWidth ? x + range : scrn.lvl.levelWidth; 
				for(i in minX...maxX)
				{
					var minY = y - range > 0 ? y - range : 0;
					var maxY = y + range < scrn.lvl.levelHeight ? x + range : scrn.lvl.levelHeight; 
					for(j in minY...maxY)
					{
						var dx:Int = Std.int(Math.abs(i - x));
						var dy:Int = Std.int(Math.abs(j - y));
						if(Math.sqrt(dx*dx + dy*dy) <= range && dx + dy >= attack.minRange) 
						{
							if(scrn.lvl.activeNodes[i + j*scrn.lvl.levelWidth].occupant != null && actor.team.isThreat(scrn.lvl.activeNodes[i + j*scrn.lvl.levelWidth].occupant.team.id))
							{
									result = scrn.lvl.activeNodes[i + j*scrn.lvl.levelWidth].occupant;
									break;
							}
						}
					}
				}
			}
		}
		return result;
	}
}