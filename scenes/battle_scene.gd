extends Node2D


signal finished(victory: bool);


func _ready() -> void:
	GameState.is_editing = false;
	
	$Aim.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	
	spawn_player_machine();
	spawn_enemy_machine();
	
	GameState.machine_left.destroyed.connect(finished.emit.bind(false), CONNECT_ONE_SHOT);
	GameState.machine_right.destroyed.connect(finished.emit.bind(true), CONNECT_ONE_SHOT);
	
	GameState.current_scene = self;


func spawn_player_machine() -> void:
	var player_machine := Machine.load_from_dictionary(GameState.player_template);
	player_machine.position = Vector2(150.0, 300.0)
	add_child(player_machine)
	GameState.machine_left = player_machine;


func spawn_enemy_machine() -> void:
	var template_machine := MachineLibrary.load_machine("starting_machine");
	var dict := template_machine.save_to_dictionary();
	template_machine.queue_free();
	
	var machine2 := Machine.load_from_dictionary(dict, "default");
	machine2.position = Vector2(1000.0, 300.0)
	machine2.reversed = true;
	add_child(machine2)
	GameState.machine_right = machine2;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton;
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			var modules := get_modules_at_point(get_global_mouse_position());
			if modules.size() > 0:
				var module : Module = modules[0];
				if module.owner.owner == GameState.machine_left:
					# user is targeting players machine
					if module.can_activate():
						module.activate();
				else:
					# user is targeting other machine
					var new_target := GameState.machine_right.grid.modules[module];
					GameState.machine_left.targeting_strategy = new_target;



func _process(_delta: float) -> void:
	var current_target = GameState.machine_left.targeting_strategy;
	$Aim.position = GameState.get_machine_grid_location(GameState.machine_right, current_target);


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
