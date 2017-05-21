let project = new Project('New Project');
project.addAssets('Assets/**');
project.addLibrary('Sdg');
project.addLibrary('haxe-format-tiled');
project.addLibrary('Delta');
project.addSources('Sources');
resolve(project);
