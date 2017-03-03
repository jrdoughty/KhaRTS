let project = new Project('New Project');
project.addAssets('Assets/**');
project.addLibrary('Sdg');
project.addLibrary('haxe-format-tiled');
project.addSources('Sources');
resolve(project);
