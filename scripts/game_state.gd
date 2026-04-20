extends Node
class_name _GameStateClass


signal editing;
signal battling;


const bounds := Rect2(-1000.0, -1000.0, 2000.0, 2000.0);
const left_machine_offset := Vector2(150.0, 300.0);

var is_editing : bool = false:
	set(v):
		if v:
			editing.emit();
		else:
			battling.emit();
		is_editing = v; 

var machine_right : Machine = null;
var machine_left : Machine = null;
var current_scene : Node2D;

var pending_rewards : Dictionary[Module, int] = {};
var player_inventory : Dictionary[Module, int] = {};


var wall_enemies := [
	"wall"
]
var easy_enemies := [
	"easy_target",
]
var medium_enemies := [
	"overengineered",
]
var hard_enemies := [
	"all_roads_lead_to_rome",
]
var boss_enemies := [
	"wall",
]

var easy_rewards := [
	[
		ModuleLibrary.get_module("tube", 0),
	],
	[
		ModuleLibrary.get_module("tube", 1),
		ModuleLibrary.get_module("tube", 2),
		ModuleLibrary.get_module("tube", 2),
		ModuleLibrary.get_module("splitter", 0),
		ModuleLibrary.get_module("splitter", 1),
		ModuleLibrary.get_module("splitter", 2),
	],
	[
		ModuleLibrary.get_module("peashooter"),
		ModuleLibrary.get_module("armor"),
		ModuleLibrary.get_module("shield"),
		ModuleLibrary.get_module("lazer gun"),
	],
]

var medium_rewards := [
	[
		ModuleLibrary.get_module("tube", 0),
		ModuleLibrary.get_module("tube", 1),
		ModuleLibrary.get_module("tube", 2),
		ModuleLibrary.get_module("splitter", 0),
		ModuleLibrary.get_module("splitter", 1),
		ModuleLibrary.get_module("splitter", 2),
		ModuleLibrary.get_module("splitter", 3),
	],
	[
		ModuleLibrary.get_module("merger", 3),
		ModuleLibrary.get_module("armor"),
		ModuleLibrary.get_module("shield"),
	],
	[
		ModuleLibrary.get_module("lazer gun"),
		ModuleLibrary.get_module("barrier"),
		ModuleLibrary.get_module("multiplicator"),
	]
]

var hard_rewards := [
	[
		ModuleLibrary.get_module("tube", 0),
		ModuleLibrary.get_module("tube", 1),
		ModuleLibrary.get_module("tube", 2),
		ModuleLibrary.get_module("splitter", 0),
		ModuleLibrary.get_module("splitter", 1),
		ModuleLibrary.get_module("splitter", 2),
		ModuleLibrary.get_module("splitter", 3),
	],
	[
		ModuleLibrary.get_module("merger", 0),
		ModuleLibrary.get_module("merger", 1),
		ModuleLibrary.get_module("merger", 2),
		ModuleLibrary.get_module("merger", 3),
		ModuleLibrary.get_module("armor"),
		ModuleLibrary.get_module("barrier"),
	],
	[
		ModuleLibrary.get_module("railgun"),
		ModuleLibrary.get_module("multiplicator"),
	]
]

var max_difficulty_cleared : int = -1;
var current_difficulty : int = 0;

var player_template : Dictionary;

# do not change when the game scenes are loaded
var gameplay_scale : float = 948.0 / 1920.0;


func _init() -> void:
	var starting_machine := MachineLibrary.load_machine("starting_machine");
	player_template = starting_machine.save_to_dictionary();
	starting_machine.queue_free();

#
#func _ready() -> void:
	#var vp: get_viewport();
	#var w 


func shoot_projectile(projectile_scene: Projectile, by: Module, global_pos: Vector2) -> void:
	if current_scene != null:
		current_scene.add_child(projectile_scene);
		projectile_scene.shooter = by;
		projectile_scene.position = current_scene.to_local(global_pos);


func get_machine_grid_location(machine: Machine, cell: Vector2i) -> Vector2:
	var position := machine.grid.grid_position_to_scene_position(cell) + machine.grid.global_position;
	
	return position;


func get_other_machine(by: Machine) -> Machine:
	var other_machine : Machine = null;
	
	if by == machine_left:
		other_machine = machine_right;
	if by == machine_right:
		other_machine = machine_left;
	
	return other_machine


func get_other_grid_location(by: Module, cell: Vector2i) -> Vector2:
	var grid : ModuleGrid = by.owner;
	var machine : Machine = grid.owner;
	var other_machine : Machine = get_other_machine(machine);
	
	if other_machine == null:
		return Vector2();
	
	return get_machine_grid_location(other_machine, cell)


func load_new_game() -> void:
	new_game();
	var intro := preload("res://scenes/godot_slides/intro.tscn").instantiate();
	get_tree().change_scene_to_node.call_deferred(intro);
	await intro.finished;
	load_editor();


func load_tutorial() -> void:
	pass;


func new_game() -> void:
	for module in player_inventory:
		module.queue_free();
	
	player_inventory.clear();


func load_creative() -> void:
	var editor := preload("res://scenes/editor_scene.tscn").instantiate();
	editor.is_creative = true;
	get_tree().change_scene_to_node.call_deferred(editor);
	await editor.finished;
	load_battle();


func load_editor() -> void:
	var editor := preload("res://scenes/editor_scene.tscn").instantiate();
	editor.is_creative = false;
	get_tree().change_scene_to_node.call_deferred(editor);
	await editor.finished;
	load_battle();


func load_battle() -> void:
	var battle := preload("res://scenes/battle_scene.tscn").instantiate();
	get_tree().change_scene_to_node.call_deferred(battle);
	var victory_achieved : bool = await battle.finished;
	
	if victory_achieved:
		max_difficulty_cleared = maxi(max_difficulty_cleared, current_difficulty)
		var rewards_pool;
		match current_difficulty:
			0, 1:
				rewards_pool = easy_rewards;
			2:
				rewards_pool = medium_rewards;
			3:
				rewards_pool = hard_rewards;
			4:
				go_to_victory_screen()
		
		for reward_slot : Array in rewards_pool:
			var module_template : Module = reward_slot.pick_random();
			pending_rewards[module_template.make_copy()] = 1;
	
	machine_left.grid.fix_all();
	player_template = machine_left.save_to_dictionary();
	load_editor();


func go_to_victory_screen() -> void:
	pass;


func go_to_menu() -> void:
	pass;
