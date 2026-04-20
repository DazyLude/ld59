extends Node2D
class_name Machine


var default_grid_position := Vector2();
@export var grid : ModuleGrid;
@export var body : Node2D;

var inventory : Dictionary[Module, int] = {};
var reversed : bool:
	set(v):
		grid.reversed = v;
		body.reversed = v;
		reversed = v;

var targeting_strategy := Vector2i(0, 0);

func _ready() -> void:
	if default_grid_position == Vector2():
		default_grid_position = grid.position;
	grid.position = default_grid_position * GameState.gameplay_scale;
	$ModuleGrid/Sprite2D.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale);
	
	if body != null:
		body.grid_ref = grid;
	
	var generator := ModuleLibrary.get_module("generator");
	var tube := ModuleLibrary.get_module("tube");
	tube.type = 0;
	var peashooter := ModuleLibrary.get_module("peashooter");
	
	var splitter := ModuleLibrary.get_module("splitter");
	splitter.type = 1;
	
	var splitter2 := ModuleLibrary.get_module("splitter");
	splitter2.type = 0;
	splitter2.rot = 1
	
	var shield := ModuleLibrary.get_module("shield");
	var barrier := ModuleLibrary.get_module("barrier");
	var armor := ModuleLibrary.get_module("armor");
	
	grid.add_module(Vector2i(0,0), generator);
	grid.add_module(Vector2i(1,0), splitter);
	grid.add_module(Vector2i(1,1), splitter2);
	grid.add_module(Vector2i(2,0), peashooter);
	
	grid.add_module(Vector2i(2,1), shield);
	grid.add_module(Vector2i(2,-1), armor);
	grid.add_module(Vector2i(0,1), barrier);
	
	print(save_to_dictionary());


func save_to_dictionary() -> Dictionary:
	var dict := {
		"modules": [],
		"inventory": [],
	};
	
	for module in grid.modules:
		var module_name = module.module_name;
		var module_position = grid.modules[module];
		dict.modules.push_back({
			"module_name": module_name,
			"position": module_position,
		})
		var module_data = module.get_data();
		if not module_data.is_empty():
			dict.modules.back()["module_data"] = module_data;
	
	for module in inventory:
		var module_name = module.module_name;
		var module_count = inventory[module];
		dict.inventory.push_back({
			"module_name": module_name,
			"count": module_count,
		})
		var module_data = module.get_data();
		if not module_data.is_empty():
			dict.inventory.back()["module_data"] = module_data;
	
	return dict;


static func load_from_dictionary(dict: Dictionary) -> Machine:
	var machine = Machine.new();
	
	for data_dict in dict.modules:
		var module := ModuleLibrary.get_module(data_dict.module_name);
		if data_dict.has("module_data"):
			module.apply_data(data_dict.module_data);
		machine.grid.add_module(data_dict.position, module);
	
	for data_dict in dict.inventory:
		var module := ModuleLibrary.get_module(data_dict.module_name);
		if data_dict.has("module_data"):
			module.apply_data(data_dict.module_data);
		machine.inventory[module] = data_dict.count
	
	return machine;
