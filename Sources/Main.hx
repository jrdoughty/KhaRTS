package;

import kha.System;
import kha.WindowOptions;
class Main {
	public static function main() {
		System.init({title: "Project", width: 1280, height: 720}, function () {
			new Project();
		});
	}
}
