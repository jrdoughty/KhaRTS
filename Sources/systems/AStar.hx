package systems ;
import world.Node;
import world.Level;


/**
 * ...
 * @author John Doughty
 */
class AStar
{
	/**
	* 
	**/
	private static var activeLevel:Level;
	/**
	 * Array of Nodes in order beginning to end
	 */
	private static var path:Array<Node> = [];
	/**
	 * possible nodes to move to
	 */
	private static var openList:Array<Node> = [];
	/**
	 * Nodes that have been looked into and calculated
	 */
	private static var closedList:Array<Node> = [];
	/**
	 * Path estimate
	 */
	private static var pathHeiristic:Int;
	/**
	 * targetNode to path to
	 */
	private static var end:Node;
	/**
	 * Fetches Array of Nodes that make up the route beginning to end to the endNode from the start Node
	 * @param	start 		Path origin
	 * @param	endNode		Desired End of Path
	 * @return				Array of Nodes from start to endNode
	 */
	public static function newPath(start:Node, endNode:Node):Array<Node>
	{
		cleanParentNodes();//ensure everying this ready
		cleanUp();
		
		path = [];
		end = endNode;
		start.heiristic = calculateHeiristic(start, end);
		start.g = 0;
		openList.push(start);
		if (calculate() && start != endNode)
		{
			cleanUp();
			path.push(end);
			var curNode = end;
			while (curNode.parentNode != null)
			{
				path.insert(0,curNode.parentNode);
				curNode = curNode.parentNode;
			}
		}
		else
		{
			path = [];
		}
		
		cleanParentNodes();
		return path;
	}
	/**
	 * resets Node Parents before a new calculation can start
	 */
	private static function cleanParentNodes()
	{
		var i:Int;
		for (i in 0...activeLevel.activeNodes.length)
		{
			activeLevel.activeNodes[i].parentNode = null;
		}
	}
	
	/**
	 * cleans up vars for new calculation
	 */
	private static function cleanUp()
	{
		var i:Int;
		for (i in 0...activeLevel.activeNodes.length)
		{
			activeLevel.activeNodes[i].g = -1;
			activeLevel.activeNodes[i].heiristic = -1;
		}
		closedList = [];
		openList = [];
	}
	

	/**
	 * calculates out the path recursively. returns true if it finds path
	 * if unable to come up with a path it returns false
	 */
	private static function calculate():Bool
	{
		while(openList.length > 0)
		{
			var closestIndex:Int = -1;

			for (i in 0...openList.length) 
			{
				if (closestIndex == -1) 
				{
					closestIndex = i;
				} 
				else if (openList[i].getFinal() < openList[closestIndex].getFinal()) 
				{
					closestIndex = i;
				}
			}

			for (i in 0...openList[closestIndex].neighbors.length) 
			{
				if (SetupChildNode(openList[closestIndex].neighbors[i], openList[closestIndex]))
				{
					return true;
				}
			}
			closedList.push(openList[closestIndex]);
			openList.splice(closestIndex, 1);
		}
		return false;
	}
	
	/**
	 * heiristic calculation, uses Manhattin Method based on:http://homepages.abdn.ac.uk/f.guerin/pages/teaching/CS1013/practicals/aStarTutorial.htm
	 * @param	childNode		Node being compared to the end node
	 * @param	endNode			End/Destination Node
	 */
	@:extern private static inline function calculateHeiristic (childNode:Node, endNode:Node)//startX:Int, startY:Int, endX:Int, endY:Int) 
	{
        var h = Std.int(10 * Math.abs(childNode.nodeX - endNode.nodeX) + 10 * Math.abs(childNode.nodeY - endNode.nodeY));
		h += childNode.modifier;
		h += childNode.occupant != null?10:0;
        return h;
    }
	
	
	/**
	 * Sets up the Parent Node after applying the actual effort required to get to the node (g). 
	 * If the node fails it is added to closedList so the next open can be checked
	 * @param	childNode node to be checked
	 * @param	parentNode to be added to the child if a better parent doesn't exist
	 * @return	whether or not it is the end
	 */
    private static function SetupChildNode(childNode:Node, parentNode:Node):Bool 
	{
        var prospectiveG:Int;

        childNode.heiristic = calculateHeiristic(childNode, end);

        if (childNode.heiristic == 0) 
		{
            childNode.parentNode = parentNode;
            return true;// done if its the end
        }
		else if (childNode.isPassible() == false)
		{
			return false;
		}
		
        if (parentNode.nodeX == childNode.nodeX || parentNode.nodeY == childNode.nodeY) 
		{
            prospectiveG = parentNode.g + 10;
			if (childNode.occupant != null)
			{
				prospectiveG += 100;
			}
        } 
		else 
		{
            prospectiveG = parentNode.g + 14;
        }
        if (prospectiveG + childNode.heiristic < childNode.getFinal() || childNode.g == -1) 
		{
            childNode.parentNode = parentNode;
            childNode.g = prospectiveG;
			var inOpenList:Bool = false;
            for (i in 0...openList.length) 
			{
                if (childNode == openList[i]) 
				{
                    inOpenList = true;
                }
            }
			if (inOpenList == false)
			{
				for (i in 0...closedList.length) 
				{
					if (childNode == closedList[i]) 
					{
						closedList.splice(i, 1);
						break;
					}
				}
				openList.push(childNode);
			}
        }
        return false;
    }

	public static function setLevel(lvl:Level)
	{
		activeLevel = lvl;
	}
}