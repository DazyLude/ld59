extends Node
class_name _GameStateClass


const bounds := Rect2(-1000.0, -1000.0, 2000.0, 2000.0);


var machines : Array[Machine] = [];


var is_edited = false;


func add_machine(machine: Machine) -> void:
	machines.push_back(machine);


func shoot_projectile(projectile_scene: Projectile, by: Module) -> void:
	if !is_edited:
		projectile_scene.direction = Vector2(1.0, 0.0);
		if by.owner.reversed: projectile_scene.direction *=Vector2(-1.0, 1.0);

		by.add_child(projectile_scene);
		projectile_scene.owner = by;
