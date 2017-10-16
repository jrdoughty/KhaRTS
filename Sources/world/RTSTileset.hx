package world;

import kha.Image;
import sdg.graphics.tiles.Tileset;

typedef Tile = {
	var id:Int;
	var type:String;
}
class RTSTileset extends Tileset
{	
	public var specialTiles:Array<Tile>= [];
	public function new(tsxFileName:String)
	{
		tsxFileName+="_tsx";
		var xmlStr = Reflect.field(kha.Assets.blobs,tsxFileName).toString();
		var xml = Xml.parse(xmlStr);
		var srcString = "";
		var tileWidth:Int = 0;
		var tileHeight:Int = 0;
		for(i in xml.elements())
		{
			tileWidth = Std.parseInt(i.get('tilewidth'));
			tileHeight = Std.parseInt(i.get('tileheight'));
			for(j in i.elements())
			{
				if(j.nodeName == 'image')
				{
					srcString = j.get('source');
					srcString = StringTools.replace(srcString,".png","");
				}
				else if (j.nodeName == 'tile')
				{
					specialTiles.push({
						id:Std.parseInt(j.get('id')),
						type:j.get('type')
					});
				}
			}
		}
		var source:Image = Reflect.field(kha.Assets.images,srcString);
		super(source, tileWidth, tileHeight);
	}	
}