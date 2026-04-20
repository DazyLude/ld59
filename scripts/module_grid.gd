extends Node2D
class_name ModuleGrid


signal heart_destroyed;


const CELL_SIZE := Vector2(64.0, 64.0);
const GRID_OFFSET := Vector2();

var reversed : bool = false :
	set(v):
		reversed = v;
		for module in modules:
			var at := modules[module];
			module.position = grid_position_to_scene_position(at);
			if v: module.point_left();
			else: module.point_right();


var modules : Dictionary[Module, Vector2i] = {};
var poll_cache : Dictionary[Module, Array] = {};

var hearts : Dictionary[Module, bool] = {};
var protectors : Dictionary[Module, Array] = {};
var barrier_active : Module = null;


func grid_position_to_scene_position(grid: Vector2i) -> Vector2:
	if reversed:
		grid *= Vector2i(-1.0, 1.0);
	
	return (Vector2(grid) * CELL_SIZE - GRID_OFFSET) * GameState.gameplay_scale;


func scene_position_to_grid_position(pos: Vector2) -> Vector2i:
	if reversed:
		pos *= Vector2(-1.0, 1.0);
	
	return (((pos / GameState.gameplay_scale) + GRID_OFFSET) / CELL_SIZE).round();


func get_module_at(at: Vector2i) -> Module:
	return modules.find_key(at);


func can_add_module(at: Vector2i, _module: Module) -> bool:
	if abs(at.x) > 3 or abs(at.y) > 3:
		return false;
	
	return modules.find_key(at) == null;


func add_module(at: Vector2i, module: Module) -> void:
	add_special(module, at);
	
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
	
	var cached : Array = poll_cache.get_or_add(module, []);
	
	if not cached.is_empty():
		# first poll outputs that haven't been cached before
		var non_cached := module.outputs.filter(func(ou): return not ou in cached);
		for output : Vector2i in non_cached:
			var output_position := module_position + output;
			var receiver := get_module_at(output_position);
			
			if receiver == null:
				continue;
			if not receiver.inputs.has(-output):
				continue;
			if not receiver.can_receive_input(orb, -output):
				continue;
			
			cached.push_back(output)
			receiver.receive_input(orb, -output);
			return;
	
	cached.clear();
	# then poll all outputs
	for output in module.outputs:
		var output_position := module_position + output;
		var receiver := get_module_at(output_position);
		
		if receiver == null:
			continue;
		if not receiver.inputs.has(-output):
			continue;
		if receiver.can_receive_input(orb, -output) == false:
			continue;
		
		cached.push_back(output)
		receiver.receive_input(orb, -output);
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
	if not receiver.inputs.has(-output):
		spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));
		return;
	if receiver.can_receive_input(orb, -output) == false:
		spawn_homeless_orb(orb, grid_position_to_scene_position(module_position));
		return;
	
	receiver.receive_input(orb, -output);


func remove_module(module: Module) -> void:
	remove_child(module);
	modules.erase(module);
	module.queue_free();


func remove_special(module: Module) -> void:
	match module.module_name:
		"generator":
			module.destroyed.disconnect(_on_heart_destroyed);
			hearts.erase(module);
		"armor":
			protectors.erase(module);


func add_special(module: Module, _at: Vector2i) -> void:
	match module.module_name:
		"generator":
			module.destroyed.connect(_on_heart_destroyed);
			hearts[module] = true;
		"armor", "shield":
			protectors[module] = [Vector2i(0, 1), Vector2i(0, -1)];


func get_protector(module: Module) -> Module:
	if barrier_active == module:
		return null;
	
	if barrier_active:
		return barrier_active;
	
	if module in protectors:
		return null;
	
	var protectee_coords := modules[module];
	for protector in protectors:
		if protector.current_hp <= 0:
			continue;
		
		var protector_coords := modules[protector];
		for offset in protectors[protector]:
			if protector_coords + offset == protectee_coords:
				return protector;
	
	return null;


func move_module(from: Vector2i, to: Vector2i, module: Module) -> void:
	module.position = grid_position_to_scene_position(to);
	modules[module] = to;


func spawn_homeless_orb(orb: Orb, at: Vector2) -> void:
	pass;


func get_ability_list() -> Array[Ability]:
	return []; 


func _on_heart_destroyed() -> void:
	for heart in hearts:
		if heart.current_hp <= 0:
			hearts[heart] = false;
	
	if not hearts.values().any(func(b): return b):
		heart_destroyed.emit();


func fix_all() -> void:
	for module in modules:
		module.current_hp = module.max_hp;
