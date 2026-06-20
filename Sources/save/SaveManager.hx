package save;

import screens.IGameScreen;
import haxe.Json;
#if sys
import sys.io.File;
#end
#if js 
import js.Browser;
#end
import haxe.io.Path;
import sdg.Sdg;

typedef GameSaveData = {
    var version:Int;
    var time:Float;
    var teams:Array<TeamSaveData>;
    var actors:Array<ActorSaveData>;
    var level:LevelSaveData;
}

typedef TeamSaveData = {
    var id:Int;
    var resources:Int;
    var allies:Array<Int>;
}

typedef ActorSaveData = {
    var id:Int;
    var x:Int;
    var y:Int;
    var bx:Int;
    var by:Int;
    var bData:String;
    var tx:Int;
    var ty:Int;
    var targetEnemy:Int;
    var health:Float;
    var data:String;
	var currentResource:String;
	var resourcesCollected:Int;
	var targetResource:Int;
	var targetBuilding:Int;
	var value:Int;
	var currentState:String;
	var nextState:String;
	var lastState:String;
    var type:String;
    var teamID:Int;
}

typedef LevelSaveData = {
    var fogReset:Bool;
    var playerStarts:Array<{team:Int, x:Float, y:Float}>;
}

class SaveManager {
    static var SAVE_FILE:String = "saves/savegame.json";
    static var SAVE_VERSION:Int = 1;
    
    public static function ensureSaveDir():Void {
        var dir = Path.directory(SAVE_FILE);
        #if sys
        if (dir != "" && !File.systemExists(dir)) {
            File.systemCreateDirectory(dir);
        }
        #end
        #if js
        Browser.window.localStorage.length > -1;//not sure this is a valid check yet
        #end
    }
    
    public static function save(state:IGameScreen):Bool 
    {
        ensureSaveDir();
        
        try {
            var saveData:GameSaveData = {
                version: SAVE_VERSION,
                time: Sdg.time(),
                teams: [],
                actors: [],
                level: { fogReset: false, playerStarts: [] }
            };
            
            // Extract your existing data structures here
            // Example extraction pattern:
            if (state != null && state.teams != null) {
                for (t in state.teams) 
                {
                    saveData.teams.push({
                        id: t.id,
                        resources: t.resources,
                        allies: t.allies
                    });

                    for (a in t.units) {
                        saveData.actors.push({
                            id: a.id,
                            x: a.currentNodes[0].nodeX,
                            y: a.currentNodes[0].nodeY,
                            tx: (a.targetNode != null)?a.targetNode.nodeX:null,
                            ty: (a.targetNode != null)?a.targetNode.nodeY:null,
                            bx: (a.buildNode != null)?a.buildNode.nodeX:null,
                            by: (a.buildNode != null)?a.buildNode.nodeY:null,
                            bData: (a.buildData != null)?a.buildData.name:null,
                            targetEnemy:(a.targetEnemy != null)?a.targetEnemy.id:null,
                            health: a.health,
                            data: cast (a.data.id,String),
                            currentResource:a.currentResource,
                            resourcesCollected:a.resourcesCollected,
                            targetResource:(a.targetResource != null)?a.targetResource.id:null,
                            targetBuilding:(a.targetBuilding != null)?a.targetBuilding.id:null,
                            value:a.value,
                            currentState:a.currentState,
                            nextState:a.nextState,
                            lastState:a.lastState,
                            type:"unit",
                            teamID:a.team.id
                        });
                    }

                    for (a in t.buildings) {
                        saveData.actors.push({
                            id: a.id,
                            x: a.currentNodes[0].nodeX,
                            y: a.currentNodes[0].nodeY,
                            tx: null,
                            ty: null,
                            bx: (a.buildNode != null)?a.buildNode.nodeX:null,
                            by: (a.buildNode != null)?a.buildNode.nodeY:null,
                            bData: (a.buildData != null)?a.buildData.name:null,
                            targetEnemy:(a.targetEnemy != null)?a.targetEnemy.id:null,
                            health: a.health,
                            data: cast (a.buildingData.id,String),
                            currentResource:a.currentResource,
                            resourcesCollected:a.resourcesCollected,
                            targetResource:(a.targetResource != null)?a.targetResource.id:null,
                            targetBuilding:(a.targetBuilding != null)?a.targetBuilding.id:null,
                            value:a.value,
                            currentState:a.currentState,
                            nextState:a.nextState,
                            lastState:a.lastState,
                            type:"building",
                            teamID:a.team.id
                        });
                    }
                }
                for (a in state.resources)
                {
                    saveData.actors.push(
                        {
                            id: a.id,
                            x: a.currentNodes[0].nodeX,
                            y: a.currentNodes[0].nodeY,
                            tx: null,
                            ty: null,
                            bx: (a.buildNode != null)?a.buildNode.nodeX:null,
                            by: (a.buildNode != null)?a.buildNode.nodeY:null,
                            bData: (a.buildData != null)?a.buildData.name:null,
                            targetEnemy:null,
                            health: a.health,
                            data: cast (a.resourceData.id,String),
                            currentResource:a.currentResource,
                            resourcesCollected:a.resourcesCollected,
                            targetResource:(a.targetResource != null)?a.targetResource.id:null,
                            targetBuilding:(a.targetBuilding != null)?a.targetBuilding.id:null,
                            value:a.value,
                            currentState:a.currentState,
                            nextState:a.nextState,
                            lastState:a.lastState,
                            type:"resource",
                            teamID:null
                        }
                    );
                }
            }
            
            var json = Json.stringify(saveData);
            #if sys
            File.saveContent(SAVE_FILE, json);
            #end
            #if js
            Browser.getLocalStorage().setItem(SAVE_FILE, json);
            #end
            trace("[SaveManager] Saved successfully to " + SAVE_FILE);
            return true;
        } catch (e:Dynamic) {
            trace("[SaveManager] Save failed: " + e);
            return false;
        }
    }
    
    public static function load():GameSaveData 
    {
        try {            
            var json:String;

            #if sys
            if (!File.exists(SAVE_FILE)) {
                trace("[SaveManager] No save file found");
                return null;
            }
            
            json = File.getContent(SAVE_FILE);
            #end
            #if js
            json = Browser.window.localStorage.getItem(SAVE_FILE);
            #end
            var raw:Dynamic = Json.parse(json);
            var data:GameSaveData = cast raw;
            
            if (data.version != SAVE_VERSION) {
                trace("[SaveManager] Version mismatch: expected $SAVE_VERSION, got ${data.version}");
                // Handle migration or return null here
            }
            
            return data;
        } catch (e:Dynamic) {
            trace("[SaveManager] Load failed: " + e);
            return null;
        }
    }
}
