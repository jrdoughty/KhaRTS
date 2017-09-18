package systems;
import kha.Assets;

class Data
{	
	public static var dataMap: Map<String, Map<String, Map<String, Dynamic>>>;

	public static function loadData()
	{
		var dataObj:Dynamic = haxe.Json.parse(Assets.blobs.database_cdb.toString());
		var dataMap: Map<String, Map<String, Map<String, Dynamic>>> = new Map<String, Map<String, Map<String, Dynamic>>>();
		var sheets = [];
		sheets = dataObj.sheets;
		for(sheet in sheets)
		{
			dataMap.set(sheet.name, new Map<String, Map<String, Dynamic>>());
			var lines:Array<Dynamic> = sheet.lines;
			for(line in lines)
			{
				dataMap[sheet.name].set(line.name, new Map<String, Dynamic>());
				for(i in Reflect.fields(line))
				{
					dataMap[sheet.name][line.name].set(i, Reflect.field(line,i));
				}
			}
		}
		systems.Data.dataMap = dataMap;
	}
}