extends Node2D
class_name Machine


var default_grid_position := Vector2();
var template : Dictionary;

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
	if reversed:
		grid.position *= Vector2(-1.0, 1.0);
	$ModuleGrid/Sprite2D.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale);
	
	if body != null:
		body.grid_ref = grid;
	
	add_modules_from_template();
	print(save_to_dictionary());


func add_modules_from_template() -> void:
	if template.has("modules"):
		for data_dict in template.modules:
			var module := ModuleLibrary.get_module(data_dict.module_name);
			if data_dict.has("module_data"):
				module.apply_data(data_dict.module_data);
			else:
				module.apply_data({});
			grid.add_module(data_dict.position, module);


func save_to_dictionary() -> Dictionary:
	if not is_node_ready():
		return template;
	
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


static func load_from_dictionary(dict: Dictionary, body_variant: String = "default") -> Machine:
	var machine_pckd = MachineLibrary.body_variants.get(body_variant, preload("res://scenes/crazy_machine.tscn"))
	var machine : Machine = machine_pckd.instantiate();
	machine.template = dict;
	
	for data_dict in dict.inventory:
		var module := ModuleLibrary.get_module(data_dict.module_name);
		if data_dict.has("module_data"):
			module.apply_data(data_dict.module_data);
		machine.inventory[module] = data_dict.count
	
	return machine;
