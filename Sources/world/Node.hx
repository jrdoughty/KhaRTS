package world;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class Node implements Util.ITwoD
{
	public var neighbors:Array<Node> = [];
	public var leftNode:Node;
	public var rightNode:Node;
	public var topNode:Node;
	public var bottomNode:Node;
	public var topLeftNode:Node;
	public var topRightNode:Node;
	public var bottomLeftNode:Node;
	public var bottomRightNode:Node;
	public var parentNode:Node;
	public var occupant:Actor = null;
	public var g:Int = -1;
	public var heiristic:Int = -1;
	public var nodeX:Int;
	public var nodeY:Int;
	public var x:Float;
	public var y:Float;
	public var width:Int;
	public var height:Int;
	public var frame:Int;
	public var removeShadow:Bool = false;
	public var passable:Bool = true;
	
	public function new(frame:Int, width:Int, height, X:Int = 0, Y:Int = 0, pass:Bool = true ) 
	{
		x = X * width;
		y = Y * height;
		//asset
		
		this.width = width;
		this.height = height;
		this.frame = frame;
		
		nodeX = X;
		nodeY = Y;
		
		passable = pass;
	}
	
	public function isPassible():Bool
	{
		return (passable);
	}
	
	public function resetState():Void
	{
		//playAnimation("main");
	}
	
	public function getFinal():Int
	{
		return heiristic + g;
	}
	

    public function getAllFromRight(widthToGo:Int):Array<Node>
    {
        var result:Array<Node> = [];
		
		if (rightNode != null)
		{
			result.push(rightNode);
			widthToGo--;
			if(widthToGo > 0)
			{
				result = result.concat(rightNode.getAllFromRight(widthToGo));
			}
		}
        return result;
    }
	
	
    public function getAllNodes(widthToGo:Int, heightToGo:Int):Array<Node>
    {
        var result:Array<Node> = [this];
		
		if (rightNode != null && widthToGo > 0)
		{
			result = result.concat(getAllFromRight(widthToGo));
		}
		if (bottomNode != null && heightToGo > 0)
		{
			heightToGo--;
			result = result.concat(bottomNode.getAllNodes(widthToGo, heightToGo));
			
		}
        return result;
    }
	
	public function removeOverlay()
	{
		removeShadow = true;
	}
	
	public function addOverlay()
	{
		removeShadow = false;
	}
}