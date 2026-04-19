extends Node2D
class_name ModuleGrid


const CELL_SIZE := Vector2(128.0, 128.0);
var reversed : bool = false :
	set(v):
		reversed = v;
		for module in modules:
			var at := modules[module];
			module.position = grid_position_to_scene_position(at);
			if v: module.point_left();
			else: module.point_right();


var modules : Dictionary[Module, Vector2i] = {};


func grid_position_to_scene_position(grid: Vector2i) -> Vector2:
	if reversed:
		grid *= Vector2i(-1.0, 1.0);
	
	return (Vector2(grid) * CELL_SIZE - CELL_SIZE / 2) * GameState.gameplay_scale;


func scene_position_to_grid_position(pos: Vector2) -> Vector2i:
	if reversed:
		pos *= Vector2(-1.0, 1.0);
	
	return (((pos / GameState.gameplay_scale) + CELL_SIZE / 2) / CELL_SIZE).round();


func get_module_at(at: Vector2i) -> Module:
	return modules.find_key(at);


func can_add_module(at: Vector2i, _module: Module) -> bool:
	return modules.find_key(at) == null;


func add_module(at: Vector2i, module: Module) -> void:
	module.spawn_output.connect(handle_output.bind(module));
	module.position = grid_position_to_scene_position(at);
	modules[module] = at;
	
	add_child(module);
	
	module.owner = self;
	if reversed:
		module.point_left();
	else:
		module.point_right();
	
	module.set_scale_modifier(GameState.gameplay_scale);


func handle_output(orb: Orb, output_idx: int, module: Module) -> void:
	if output_idx == -1:
		poll_outputs(orb, module);
	else:
		request_output(orb, output_idx, module);


func poll_outputs(orb: Orb, module: Module) -> void:
	var module_position := modules[module];
	
	for output in module.outputs:
		var output_position := module_position + output;
		var receiver := get_module_at(output_position);
		
		if receiver == null:
			continue;
		if not receiver.inputs.has(- output):
			continue;
		if receiver.can_receive_input(orb) == false:
			continue;
		
		receiver.receive_input(orb);
		return;
	
	spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));


func request_output(orb: Orb, output_idx: int, module: Module) -> void:
	var module_position := modules[module];
	if output_idx < 0 or output_idx >= module.outputs.size():
		push_error("wrong output index in module %s" % module.module_name)
		return;
	
	var output := module.outputs[output_idx];
	var output_position := module_position + output;
	
	var receiver := get_module_at(output_position);
	
	if receiver == null:
		spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));
		return;
	if not receiver.inputs.has(- output):
		spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));
		return;
	if receiver.can_receive_input(orb) == false:
		spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));
		return;
	
	receiver.receive_input(orb);


func remove_module(module: Module) -> void:
	remove_child(module);
	modules.erase(module);
	module.queue_free();


func move_module(from: Vector2i, to: Vector2i, module: Module) -> void:
	module.position = grid_position_to_scene_position(to);
	modules[module] = to;


func spawn_homeless_orb(orb: Orb, at: Vector2) -> void:
	pass;


func get_ability_list() -> Array[Ability]:
	return []; 
