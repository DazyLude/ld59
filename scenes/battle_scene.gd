extends Node2D


func _ready() -> void:
	GameState.is_editing = false;
	
	$Aim.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	
	var machine_pckd = preload("res://scenes/crazy_machine.tscn");
	
	var machine1 : Machine = machine_pckd.instantiate()
	GameState.add_machine(machine1)
	machine1.position = Vector2(150.0, 300.0)
	add_child(machine1)
	GameState.machine_left = machine1;
	
	var machine2 : Machine = machine_pckd.instantiate();
	GameState.add_machine(machine_pckd.instantiate())
	machine2.position = Vector2(1000.0, 300.0)
	machine2.reversed = true;
	add_child(machine2)
	GameState.machine_right = machine2;
	
	GameState.current_scene = self;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton;
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			var modules := get_modules_at_point(get_global_mouse_position());
			if modules.size() > 0:
				var module : Module = modules[0];
				if module.owner.owner == GameState.machine_left:
					# user is targeting players machine
					# TODO if module can activate - activate 
					pass;
				else:
					# user is targeting other machine
					var new_target := GameState.machine_right.grid.modules[module];
					GameState.machine_left.targeting_strategy = new_target;
					pass;


func _process(delta: float) -> void:
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
