package world;

/**
 * @author John Doughty
 */

typedef TileSet = {
	var firstgid:Int;
	var image:String;
	var imageheight:Int;
	var imagewidth:Int;
	var margin:Int;
	var name:String;
	var spacing:Int;
	var tileheight:Int;
	var tilewidth:Int;
}

typedef Layer = {
	var data:Array<Int>;
	var height:Int;
	var name:String;
	var opacity:Float;
	var type:String;
	var visible:Bool;
	var width:Int;
	var x:Int;
	var y:Int;
}
 
typedef TiledLevel = {
	var height:Int;
	var width:Int;
	var layers:Array<Layer>;
	var tileheight:Int;
	var tilesets:Array<TileSet>;
	var tilewidth:Int;
}