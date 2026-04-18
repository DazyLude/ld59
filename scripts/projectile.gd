extends Area2D
class_name Projectile


@export var damage : float;
@export var speed : float;
var direction : Vector2;


func _ready() -> void:
	area_entered.connect(check_module_collision)


func _physics_process(delta: float) -> void:
	self.position += speed * direction * delta;
	if not GameState.bounds.has_point(self.position):
		queue_free();


func check_module_collision(another_area: Area2D) -> void:
	if another_area.owner != null \
		and not another_area is Projectile \
		and another_area.owner is Module \
		and another_area.owner.owner != self.owner.owner:
			var colidee : Module = another_area.owner;
			colidee.receive_damage(damage)
			_on_contact();


func _on_contact() -> void:
	queue_free();
