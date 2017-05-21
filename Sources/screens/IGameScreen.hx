package screens;
import systems.Team;
import world.Level;
import sdg.Object;
//import dashboard.Dashboard;

/**
 * @author John Doughty
 */
interface IGameScreen 
{
	public var lvl:Level;
	public var teams(default,null):Array<Team>;
	public var activeTeam(default,null):Team;
	public var dashboard(default,null):Object;//Dashboard;
}