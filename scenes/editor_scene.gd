extends Node2D


signal finished;


var is_creative : bool = true;

@export var module_selector_root : Control;
@onready var rewards_root : Control = $CanvasLayer/Rewards/Rewards/HBoxContainer;

var currently_selected : Module;
var temporary_added : Module:
	set(v):
		if temporary_added == v:
			return;
		
		if temporary_added != null:
			temporary_added.queue_free();
		
		temporary_added = v;
var temporary_position : Vector2i;

var modules_instantiated : Array[Module] = [];


func _ready() -> void:
	GameState.is_editing = true;
	$BG.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	
	spawn_player_machine();
	
	$CanvasLayer/ControlPanel/Load.visible = is_creative;
	$CanvasLayer/ControlPanel/Label.visible = is_creative;
	
	$CanvasLayer/ControlPanel/Save.pressed.connect(save_to_clipboard)
	$CanvasLayer/ControlPanel/Load.pressed.connect(load_from_clipboard)
	$CanvasLayer/GamePanel/Continue.pressed.connect(try_continue)
	
	$CanvasLayer/Tools/E.pressed.connect(try_rotate.bind(1))
	$CanvasLayer/Tools/Q.pressed.connect(try_rotate.bind(-1))
	
	$CanvasLayer/DifficultySelect/VBoxContainer/Hide.pressed.connect(hide_difficulty_select)
	
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button.pressed.connect(
		choose_difficulty_and_start.bind(1)
	);
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button2.visible = GameState.max_difficulty_cleared >= 1
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button2.pressed.connect(
		choose_difficulty_and_start.bind(2)
	);
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button3.visible = GameState.max_difficulty_cleared >= 2
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button3.pressed.connect(
		choose_difficulty_and_start.bind(3)
	);
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button4.visible = GameState.max_difficulty_cleared >= 3
	$CanvasLayer/DifficultySelect/VBoxContainer/HBoxContainer/Button4.pressed.connect(
		choose_difficulty_and_start.bind(4)
	);
	
	$CanvasLayer/Rewards/Rewards/Hide.pressed.connect($CanvasLayer/Rewards.hide)
	
	if not GameState.pending_rewards.is_empty():
		render_pending_rewards();
	
	spawn_inventory();


func _exit_tree() -> void:
	for module in modules_instantiated:
		module.queue_free()


func _process(_d: float) -> void:
	if currently_selected != null:
		currently_selected.position = get_local_mouse_position();
		
		var grid := GameState.machine_left.grid;
		var grid_pos := grid.scene_position_to_grid_position(
			grid.get_local_mouse_position()
		)
		
		if temporary_added != null and grid_pos == temporary_position:
			return;
		
		if grid.can_add_module(grid_pos, currently_selected):
			if temporary_added != null:
				grid.remove_module(temporary_added);
				temporary_added = null;
			
			temporary_added = currently_selected.make_copy();
			temporary_added.turn_shadow();
			grid.add_module(grid_pos, temporary_added)
			temporary_position = grid_pos;
		else:
			if temporary_added != null:
				grid.remove_module(temporary_added);
				temporary_added = null;


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"rotate_ccw"):
		try_rotate(-1);
	
	if event.is_action_pressed(&"rotate_cw"):
		try_rotate(+1);
	
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton;
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			if temporary_added != null:
				BgmPlayer.play_one_off(BgmPlayer.SoundID.GridClick2)
				if not is_creative:
					# remove from inventory
					GameState.player_inventory.erase(currently_selected);
					currently_selected.queue_free();
					spawn_inventory();
				
				temporary_added.turn_normal();
				
				var grid := GameState.machine_left.grid;
				grid.remove_module(temporary_added);
				grid.add_module(temporary_position, temporary_added.make_copy());
				
				temporary_added = null;
				module_picked(null);
				return;
			
			if currently_selected == null:
				var colliders := get_modules_at_point(get_global_mouse_position());
				if colliders.size() > 0:
					BgmPlayer.play_one_off(BgmPlayer.SoundID.GridClick)
					temporary_added = colliders[0];
					
					var module_copy = temporary_added.make_copy();
					if not is_creative:
						# put to inventory
						GameState.player_inventory[module_copy] = 1;
						spawn_inventory();
					else:
						modules_instantiated.push_back(module_copy);
					
					var grid := GameState.machine_left.grid;
					temporary_position = grid.modules[temporary_added];
					temporary_added.turn_shadow();
					module_picked(module_copy);
					return;
		
		if mb_event.button_index == MOUSE_BUTTON_RIGHT and mb_event.pressed:
			if currently_selected != null:
				if temporary_added != null:
					var grid := GameState.machine_left.grid;
					grid.remove_module(temporary_added);
					temporary_added = null;
				module_picked(null);
				return;


func spawn_player_machine() -> void:
	var machine = Machine.load_from_dictionary(GameState.player_template);
	set_machine(machine);


func set_machine(machine: Machine) -> void:
	if GameState.machine_left != null and GameState.machine_left in get_children():
		remove_child(GameState.machine_left)
		GameState.machine_left.queue_free();
	
	GameState.machine_left = machine;
	add_child(machine);
	machine.position = GameState.left_machine_offset;


func get_modules_at_point(point: Vector2) -> Array:
	var query := PhysicsPointQueryParameters2D.new();
	
	query.position = point;
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	
	var intersects := get_world_2d().direct_space_state.intersect_point(query);
	var colliders := intersects.map(func(d: Dictionary) -> Area2D : return d.collider);
	colliders = colliders.map(func(c: Area2D) -> Node2D: return c.owner);
	colliders = colliders.filter(func(c: Node2D) -> bool: return c is Module);
	
	return colliders;


func spawn_inventory() -> void:
	for child in module_selector_root.get_children():
		child.queue_free();
	
	if is_creative:
		spawn_all_items();
	else:
		spawn_inventory_items();


func spawn_inventory_items() -> void:
	for module in GameState.player_inventory:
		var count := GameState.player_inventory[module];
		add_button_for_module(module, count);


func render_pending_rewards() -> void:
	for module in GameState.pending_rewards:
		GameState.player_inventory[module] = 1;
		var button : ModuleButton = preload("res://scenes/scene_elements/module_select.tscn").instantiate()
		add_child(module);
		remove_child(module);
		button.icon = module.icon;
		button.pressed.connect(module_picked.bind(module))
		rewards_root.add_child(button);
	
	GameState.pending_rewards.clear();
	$CanvasLayer/Rewards.show();


func spawn_all_items() -> void:
	for item_name in ModuleLibrary.module_packed_scenes.keys():
		var module : Module;
		match item_name:
			"tube": # need to add all 3 types and 4 rotations
				for t in range(3):
					module = ModuleLibrary.get_module("tube")
					module.type = t;
					modules_instantiated.push_back(module);
					add_button_for_module(module, 1);
			"splitter": # need to add all 4 types and 4 rotations
				for t in range(4):
					module = ModuleLibrary.get_module("splitter")
					module.type = t;
					modules_instantiated.push_back(module);
					add_button_for_module(module, 1);
			"merger": # need to add all 4 types and rotations
				for t in range(4):
					module = ModuleLibrary.get_module("merger")
					module.type = t;
					modules_instantiated.push_back(module);
					add_button_for_module(module, 1);
			_:
				module = ModuleLibrary.get_module(item_name);
				modules_instantiated.push_back(module);
				add_button_for_module(module, 1);


func add_button_for_module(module: Module, _count: int) -> void:
	var button : ModuleButton = preload("res://scenes/scene_elements/module_select.tscn").instantiate()
	add_child(module);
	remove_child(module);
	button.icon = module.icon;
	button.pressed.connect(module_picked.bind(module))
	module_selector_root.add_child(button);


func module_picked(module: Module) -> void:
	if currently_selected == module and module != null:
		despawn_ghost(currently_selected);
		currently_selected = null;
		return;
	
	if currently_selected != null:
		despawn_ghost(currently_selected)
		currently_selected = null;
	
	if module != null:
		currently_selected = module;
		spawn_ghost(currently_selected);


func spawn_ghost(module: Module) -> void:
	add_child(module);
	module.turn_shadow();
	module.position = get_local_mouse_position();


func despawn_ghost(module: Module) -> void:
	remove_child(module);
	module.turn_normal();


func save_to_clipboard() -> void:
	var d := GameState.machine_left.save_to_dictionary();
	var string := JSON.stringify(JSON.from_native(d));
	DisplayServer.clipboard_set(string);
	
	#var bytes := var_to_bytes(string);
	#var compressed_bytes := bytes.compress();
	#var compressed_bytes_string := compressed_bytes.hex_encode()


func load_from_clipboard() -> void:
	var d := DisplayServer.clipboard_get();
	var json := JSON.new()
	var error := json.parse(d)
	if error == OK:
		var data = JSON.to_native(json.data);
		if typeof(data) == TYPE_DICTIONARY:
			var machine = Machine.load_from_dictionary(data);
			if machine != null:
				set_machine(machine);


func try_continue() -> void:
	if GameState.machine_left.grid.modules.keys().all(
		func(module: Module) -> bool: return module.module_name != "generator"):
			spawn_notification(
				"Can't continue: Machine has no heart.",
				2.5,
				get_global_mouse_position() - Vector2(0.0, 10.0)
			);
			return;
	
	if GameState.max_difficulty_cleared >= 0:
		show_difficulty_select()
	else:
		GameState.machine_left.grid.fix_all();
		GameState.player_template = GameState.machine_left.save_to_dictionary();
		finished.emit();


func show_difficulty_select() -> void:
	$CanvasLayer/DifficultySelect.show();


func hide_difficulty_select() -> void:
	$CanvasLayer/DifficultySelect.hide();


func choose_difficulty_and_start(diff: int) -> void:
	GameState.machine_left.grid.fix_all();
	GameState.player_template = GameState.machine_left.save_to_dictionary();
	GameState.current_difficulty = diff;
	finished.emit();


func try_rotate(direction: int) -> void:
	if currently_selected == null:
		spawn_notification(
			"Hold a module to rotate",
			2.5,
			get_global_mouse_position() - Vector2(0.0, 10.0)
		);
		return;
	
	if currently_selected.get(&"rot") == null:
		spawn_notification(
			"This module refuses to rotate",
			2.5,
			get_global_mouse_position() - Vector2(0.0, 10.0)
		);
		return;
	
	BgmPlayer.play_one_off(BgmPlayer.SoundID.GridClick3)
	currently_selected.rot += direction;
	if temporary_added != null:
		temporary_added.rot += direction;


func spawn_notification(text: String, lifetime: float, at: Vector2) -> void:
	var tween := create_tween();
	
	var noto := Label.new();
	var starting_position := at;
	var speed := Vector2(0.0, -50.0);
	
	noto.position = starting_position;
	noto.text = text;
	
	add_child(noto);
	tween.tween_property(noto, ^"position", starting_position + speed * lifetime, lifetime);
	tween.tween_callback(noto.queue_free);
