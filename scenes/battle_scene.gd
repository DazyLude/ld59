extends Node2D


signal finished(victory: bool);


func _ready() -> void:
	GameState.is_editing = false;
	
	$BG.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	$Aim.scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	
	match GameState.current_difficulty:
		0:
			$BG.texture = GameState.wall_bgs.pick_random();
		_:
			$BG.texture = GameState.bgs.pick_random();
	
	$CanvasLayer/Control/HBoxContainer/Button.pressed.connect(set_speed.bind(1))
	$CanvasLayer/Control/HBoxContainer/Button2.pressed.connect(set_speed.bind(2))
	$CanvasLayer/Control/HBoxContainer/Button3.pressed.connect(set_speed.bind(4))
	
	$CanvasLayer/Control/VBoxContainer/Surrender.pressed.connect(finished.emit.bind(false));
	
	spawn_player_machine();
	spawn_enemy_machine();
	
	GameState.machine_left.destroyed.connect(finished.emit.bind(false), CONNECT_ONE_SHOT);
	GameState.machine_right.destroyed.connect(finished.emit.bind(true), CONNECT_ONE_SHOT);
	
	GameState.current_scene = self;


func _exit_tree() -> void:
	set_speed(1);


func spawn_player_machine() -> void:
	var player_machine := Machine.load_from_dictionary(GameState.player_template);
	player_machine.position = GameState.left_machine_offset
	add_child(player_machine)
	GameState.machine_left = player_machine;


func spawn_enemy_machine() -> void:
	var enemy : String;
	var pack : String;
	match GameState.current_difficulty:
		0:
			enemy = GameState.wall_enemies.pick_random();
			pack = GameState.wall_types.pick_random();
			$BG.texture = GameState.wall_bgs.pick_random();
		1:
			enemy = GameState.easy_enemies.pick_random();
			pack = GameState.easy_types.pick_random();
			$BG.texture = GameState.bgs.pick_random();
		2:
			enemy = GameState.medium_enemies.pick_random();
			pack = GameState.medium_types.pick_random();
			$BG.texture = GameState.bgs.pick_random();
		3:
			enemy = GameState.hard_enemies.pick_random();
			pack = GameState.hard_types.pick_random();
			$BG.texture = GameState.bgs.pick_random();
		4:
			enemy = GameState.boss_enemies.pick_random();
			pack = GameState.boss_types.pick_random();
			$BG.texture = GameState.bgs.pick_random();
	
	var template_machine := MachineLibrary.load_machine(enemy);
	var dict := template_machine.save_to_dictionary();
	template_machine.queue_free();
	
	var machine2 := Machine.load_from_dictionary(dict, "default");
	machine2.position = Vector2(700.0, 300.0)
	machine2.reversed = true;
	add_child(machine2)
	machine2.body.set_textures(pack);
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


func set_speed(speed: int) -> void:
	Engine.time_scale = speed;
	Engine.physics_ticks_per_second = 60 * speed;
