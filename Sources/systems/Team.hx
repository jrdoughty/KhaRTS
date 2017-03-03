package systems;

import actors.Actor;
import actors.Actor;

/**
 * ...
 * @author John Doughty
 */
class Team
{
	public var units:Array<Actor> = [];
	public var buildings:Array<Actor> = [];
	public var allies:Array<Int> = [];
	public var id(default, null):Int;
	public var resources:Int = 400;
	/**
	 * static count of teams activated that should allow unique Int ids
	 */
	private static var teamIds = 0;
	
	/**
	 * Organizer class that holds units, buildings, and has resources assigned
	 */
	public function new() 
	{
		id = teamIds++;
	}
	/**
	 * Adds unit to flxUnits and sets unit's team
	 * @param	unit	Unit to be added to Team
	 */
	public function addUnit(unit:Actor):Void
	{
		units.push(unit);
		unit.team = this;
	}
	/**
	 * Adds building to flxBuildings and sets building's team
	 * not sure whether or not to make it use the Building class vs BaseActor
	 * @param	building	Building/BaseActor to be added
	 */
	public function addBuilding(building:Actor):Void
	{
		buildings.push(building);
		building.team = this;
	}
	
	/**
	 * If ally isn't already ally, add team to allies
	 * @param	team 	Team to add to allies
	 */
	public function addAlly(team:Team):Void
	{
		if (allies.indexOf(team.id) == -1)
		{
			allies.push(team.id);
			if (team.allies.indexOf(id) == -1)
			{
				team.addAlly(this);
			}
		}
	}
	
	
	/**
	 * If ally is a part of allies, remove them from
	 * @param	team 	Team to add to allies
	 */
	public function removeAlly(team:Team):Void
	{
		if (allies.indexOf(team.id) != -1)
		{
			allies.splice(allies.indexOf(team.id), 1);
			if (team.allies.indexOf(team.id) != -1)
			{
				team.removeAlly(this);
			}
		}
	}
	
	/**
	 * decides if the id belongs to the this Team or its allies
	 * @param	id	Int id of team
	 * @return	is this team a threat
	 */
	public function isThreat(id:Int):Bool
	{
		if (allies.indexOf(id) != -1 || id == this.id)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	
	/**
	 * decides if the team belongs is this Team or if it's an ally
	 * @param	team	Team to be verified
	 * @return	is this team a threat
	 */
	public function isTeamThreat(team:Team):Bool
	{
		if (allies.indexOf(team.id) != -1 || team.id == id)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	public function update()
	{
		for (unit in units)
		{
			if (unit.alive)
			{
				unit.update();
				if (unit.alive == false)
				{
					units.splice(units.indexOf(unit), 1);
				}
			}
		}
	}
}