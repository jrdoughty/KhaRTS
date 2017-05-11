package;
import haxe.Constraints.Function;
import sdg.Object;
/**
 * ...
 * @author John Doughty
 */


typedef OverlappingObjects = {
	group1:Array<Dynamic>,
	group2:Array<Dynamic>
}

interface ITwoD {
	public var x:Float;
	public var y:Float;
	public var width:Int;
	public var height:Int;
}

class Util
{	
	public static function doObjectsOverlap(object1:Object, object2:Object):Bool
	{
		var topLeftX1:Float = object1.width >= 0 ? object1.x : object1.x + object1.width;
		var topLeftY1:Float = object1.height >= 0 ? object1.y : object1.y + object1.height;
		var bottomRightX1:Float = object1.width >= 0 ? object1.x + object1.width : object1.x;
		var bottomRightY1:Float = object1.height >= 0 ? object1.y + object1.height : object1.y;
		

		var topLeftX2:Float = object2.width >= 0 ? object2.x : object2.x + object2.width;
		var topLeftY2:Float = object2.height >= 0 ? object2.y : object2.y + object2.height;
		var bottomRightX2:Float = object2.width >= 0 ? object2.x + object2.width : object2.x;
		var bottomRightY2:Float = object2.height >= 0 ? object2.y + object2.height : object2.y;
		
		if (topLeftX1 > bottomRightX2 || topLeftX2 > bottomRightX1 || topLeftY1 > bottomRightY2 || topLeftY2 > bottomRightY1)
		{
			return false;
		}
		return true;
	}
	public static function doObjectandITwoDOverlap(object1:Object, object2:ITwoD):Bool
	{
		var topLeftX1:Float = object1.width >= 0 ? object1.x : object1.x + object1.width;
		var topLeftY1:Float = object1.height >= 0 ? object1.y : object1.y + object1.height;
		var bottomRightX1:Float = object1.width >= 0 ? object1.x + object1.width : object1.x;
		var bottomRightY1:Float = object1.height >= 0 ? object1.y + object1.height : object1.y;
		

		var topLeftX2:Float = object2.width >= 0 ? object2.x : object2.x + object2.width;
		var topLeftY2:Float = object2.height >= 0 ? object2.y : object2.y + object2.height;
		var bottomRightX2:Float = object2.width >= 0 ? object2.x + object2.width : object2.x;
		var bottomRightY2:Float = object2.height >= 0 ? object2.y + object2.height : object2.y;

		
		if (topLeftX1 > bottomRightX2 || topLeftX2 > bottomRightX1 || topLeftY1 > bottomRightY2 || topLeftY2 > bottomRightY1)
		{
			return false;
		}
		return true;
	}
	
	public static function groupOverlap(objects1:Array<Object>, objects2:Array<Object>):OverlappingObjects
	{
		var result:OverlappingObjects = {group1:[], group2:[]};
		var i:Int;
		var j:Int;
		
		for (i in 0...objects1.length)
		{
			for (j in 0...objects2.length)
			{
				if (doObjectsOverlap(objects1[i], objects2[j]))
				{
					result.group1.push(objects1[i]);
					result.group2.push(objects2[j]);
					
				}
			}
		}
		
		return result;
	}
	
	public static function emulateFlxGOverlap(objects1:Array<Object>, objects2:Array<Object>, callback:Function):Bool
	{
		var i:Int;
		var result = false;
		var overlappingObjects:OverlappingObjects = groupOverlap(objects1, objects2);
		for (i in 0...overlappingObjects.group1.length)
		{
			callback(overlappingObjects.group1[i], overlappingObjects.group2[i]);
			result = true;
		}
		return result;
	}
}