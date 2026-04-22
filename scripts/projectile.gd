extends Area2D
class_name Projectile


@export var damage : float;
@export var speed : float;
@export var hitsound : BgmPlayer.SoundID = BgmPlayer.SoundID.FXPeaHit;
var direction : Vector2;
var shooter : Node;


func _ready() -> void:
	area_entered.connect(check_module_collision)
	scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale);


func _physics_process(delta: float) -> void:
	self.position += speed * direction * delta * GameState.gameplay_scale;
	if not GameState.bounds.has_point(self.position):
		queue_free();


func check_module_collision(another_area: Area2D) -> void:
	if another_area.owner != null \
		and not another_area is Projectile \
		and another_area.owner is Module \
		and another_area.owner.owner != shooter.owner:
			var colidee : Module = another_area.owner;
			colidee.receive_damage(damage)
			_on_contact();


func _on_contact() -> void:
	BgmPlayer.play_one_off(hitsound);
	queue_free();
