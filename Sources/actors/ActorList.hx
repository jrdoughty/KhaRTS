package actors;

import world.Node;
import sdg.event.IEventDispatcher;
import haxe.Constraints.Function;
import sdg.event.EventSystem;
import sdg.event.EventObject;
import events.TargetEvent;
import events.MoveEvent;

class ActorList
{
	public var list:Array<Actor>;
	public function new() 
	{
		list = [];
	}

	public function iterator()
	{
		return list.iterator();
	}

	public function target(a:Actor)
	{
		for(actor in list)
		{
			actor.eventDispatcher.dispatchEvent(TargetEvent.ATTACK_ACTOR, new TargetEvent(a));
		}
	}

	public function moveTo(node:Node)
	{
		var nodes:Array<Node> = [node];
		var lastLength:Int = 1;
		var i:Int = 0;
		while(nodes.length < list.length)
		{
			lastLength = nodes.length;
			for(k in nodes[i].neighbors)
			{
				if(nodes.indexOf(k) == -1 && k.isPassible())
				{
					nodes.push(k);
				}
			}
			i++;
		}

		i = 0;
		for(actor in list)
		{
			actor.eventDispatcher.dispatchEvent(MoveEvent.MOVE, new MoveEvent(nodes[i], false));
			i++;
			if(i == nodes.length)
				break;
		}
	}

	public inline function push(a:Actor):Int
	{
		return list.push(a);
	}

	public inline function indexOf(a:Actor):Int
	{
		return list.indexOf(a);
	}

	public inline function concat( a : Array<Actor> ) : Array<Actor>
	{
		return list.concat(a);
	}

	public inline function pop() : Null<Actor>
	{
		return list.pop();
	}

	public inline function reverse() : Void
	{
		list.reverse();
	}

	public inline function shift() : Null<Actor>
	{
		return list.shift();
	}

	public inline function slice( pos : Int, ?end : Int ) : Array<Actor>
	{
		return list.slice(pos,end);
	}

	public inline function sort( f : Actor -> Actor -> Int ) : Void
	{
		list.sort(f);
	}

	public inline function splice( pos : Int, len : Int ) : Array<Actor>
	{
		return splice(pos,len);
	}

	public inline function toString() : String
	{
		return list.toString();
	}

	public inline function unshift( a : Actor ) : Void
	{
		list.unshift(a);
	}

	inline function insert( pos : Int, a : Actor ) : Void 
	{
		list.insert(pos,a);
	}

	inline function remove( a : Actor ) : Bool 
	{
		return list.remove(a);
	}

}