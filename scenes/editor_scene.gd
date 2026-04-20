extends Node2D


signal finished;


var is_creative : bool = true;

@export var module_selector_root : Control;

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
	
	var machine_pckd = preload("res://scenes/crazy_machine.tscn");
	
	var machine1 : Machine = machine_pckd.instantiate()
	
	set_machine(machine1)
	
	$CanvasLayer/ControlPanel/Load.visible = is_creative;
	$CanvasLayer/ControlPanel/Label.visible = is_creative;
	
	$CanvasLayer/ControlPanel/Save.pressed.connect(save_to_clipboard)
	$CanvasLayer/ControlPanel/Load.pressed.connect(load_from_clipboard)
	$CanvasLayer/GamePanel/Continue.pressed.connect(try_continue)
	
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
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton;
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			if temporary_added != null:
				if not is_creative:
					# TODO remove from inventory
					pass;
				
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
					temporary_added = colliders[0];
					
					var module_copy = temporary_added.make_copy();
					if not is_creative:
						# TODO put to inventory
						pass;
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


func set_machine(machine: Machine) -> void:
	if GameState.machine_left != null and GameState.machine_left in get_children():
		remove_child(GameState.machine_left)
		GameState.machine_left.queue_free();
	
	GameState.machine_left = machine;
	add_child(machine);
	machine.position = Vector2(150.0, 300.0)


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
	for module in GameState.machine_left.inventory:
		var count := GameState.machine_left.inventory[module];
		add_button_for_module(module, count);


func spawn_all_items() -> void:
	for item_name in ModuleLibrary.module_packed_scenes.keys():
		var module : Module;
		match item_name:
			"tube": # need to add all 3 types and 4 rotations
				for t in range(3):
					for r in range(4):
						module = ModuleLibrary.get_module("tube")
						module.type = t;
						module.rot = r;
						modules_instantiated.push_back(module);
						add_button_for_module(module, 1);
			"splitter": # need to add all 4 types and 4 rotations
				for t in range(4):
					for r in range(4):
						module = ModuleLibrary.get_module("splitter")
						module.type = t;
						module.rot = r;
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
	if GameState.machine_left.grid.hearts.is_empty():
		spawn_notification(
			"Can't continue: Machine has no heart.",
			2.5,
			get_global_mouse_position() - Vector2(0.0, 10.0)
		);
		return;
	
	GameState.player_template = GameState.machine_left.save_to_dictionary();
	finished.emit();


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
