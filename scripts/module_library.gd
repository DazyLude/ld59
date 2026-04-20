extends Node
class_name _ModuleLibClass


## modules are referenced statically atm
var module_paths : Array[String] = [
	"res://scenes/modules/generator.tscn",
	"res://scenes/modules/peashooter.tscn",
	"res://scenes/modules/lazgun.tscn",
	"res://scenes/modules/railgun.tscn",
	"res://scenes/modules/tube.tscn",
	"res://scenes/modules/splitter.tscn",
	"res://scenes/modules/armor.tscn",
	"res://scenes/modules/barrier.tscn",
	"res://scenes/modules/shield.tscn",
	"res://scenes/modules/merger.tscn",
	"res://scenes/modules/super_generator.tscn",
];

## this thing is populated from module paths
## key is the name of a module
var module_packed_scenes : Dictionary[String, PackedScene] = {}


func _init() -> void:
	for path in module_paths:
		var pckd : PackedScene = load(path);
		var loaded : Module = pckd.instantiate();
		var module_name = loaded.module_name; 
		if module_name == "":
			push_error("empty module name encountered: %s" % path);
			continue;
		if module_packed_scenes.has(module_name):
			push_error("duplicate name encountered: %s in %s" % [module_name, path]);
			continue;
		
		module_packed_scenes[module_name] = pckd;


@warning_ignore("shadowed_variable_base_class")
func get_module(name: String) -> Module:
	if name in module_packed_scenes:
		return module_packed_scenes[name].instantiate();
	
	push_error("module with a \"%s\" name not found." % name);
	return null;
