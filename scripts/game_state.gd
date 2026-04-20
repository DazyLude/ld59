extends Node
class_name _GameStateClass


const bounds := Rect2(-1000.0, -1000.0, 2000.0, 2000.0);

var is_editing : bool = false; 

var machines : Array[Machine] = [];
var machine_right : Machine = null;
var machine_left : Machine = null;
var current_scene : Node2D;

# do not change when the game scenes are loaded
var gameplay_scale : float = 0.66;


func add_machine(machine: Machine) -> void:
	machines.push_back(machine);


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
