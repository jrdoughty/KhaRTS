package;

import kha.System;
import kha.WindowOptions;
class Main {
	public static function main() {
		/*System.init({title: "Project", width: 1280, height: 960}, function () {
			new Project();
		});*/
		System.start({
			title:"KhaRTS",
			width:1280,
			height:960
		},
		function(_){
			new Project();
		});
	}
}
