extends Node2D

@onready var current_machine := $CurrentMachine;
@onready var inventory := $ScrollContainer/Inventory;
@onready var vp_size = get_viewport().size;


func move_module_inside_machine(machine: Machine) -> void:
	pass


func move_from_inventory() -> void:
	pass


func _on_input_event(_viewport, event: InputEvent, _shape, _name_of_clicked_area):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print('clicked!')


func _ready() -> void:
	$ScrollContainer.position = Vector2(vp_size[0] / 2, 0);
	$ScrollContainer.size = Vector2(vp_size[0] / 2, vp_size[1]);
	GameState.is_edited = true;
	
	var machine_pckd = preload("res://scenes/crazy_machine.tscn");
	var machine1 : Machine = machine_pckd.instantiate();
	machine1.position = Vector2(0.0, 0.0);
	current_machine.add_child(machine1);
	
	inventory.columns = 4;
	for item in machine1.inventory:
		for _n in range(machine1.inventory[item]):
			var texture : TextureRect = TextureRect.new();
			texture.texture = item.get_child(0).texture;
			
			var area : Area2D = item.get_child(1).duplicate();
			area.input_event.connect(_on_input_event.bind(area.name));
			
			texture.add_child(area);
			inventory.add_child(texture);
