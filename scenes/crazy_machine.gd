extends Node2D
class_name Machine


@onready var grid : ModuleGrid = $ModuleGrid;
@onready var inventory : Dictionary[Module, int] = {};


func add_module(at: Vector2i, module: Module) -> void:
	grid.add_module(at, module);


func _ready() -> void:
	grid.position = Vector2(150., 150.)
	
	var generator := preload("res://scenes/modules/generator.tscn").instantiate();
	var tube := preload("res://scenes/modules/tube.tscn").instantiate();
	tube.type = 0;
	var peashooter := preload("res://scenes/modules/peashooter.tscn").instantiate();
	
	var generator2 : Module = preload("res://scenes/modules/generator.tscn").instantiate();
	inventory = {generator2 : 1}
	
	grid.add_module(Vector2i(0,0), generator);
	grid.add_module(Vector2i(1,0), tube);
	grid.add_module(Vector2i(2,0), peashooter);
