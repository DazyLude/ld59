extends Node2D
class_name OrbRenderer


func _ready() -> void:
	scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)


func render_orb(orb: Orb) -> void:
	pass;
