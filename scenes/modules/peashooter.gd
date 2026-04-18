extends Module


func can_receive_input(_orb: Orb) -> bool:
	return true


func receive_input(_orb: Orb) -> void:
	var pea := preload("res://scenes/entities/pea.tscn").instantiate();
	pea.position = $OutPosition.position;
	GameState.shoot_projectile(pea, self);


func point_left() -> void:
	$Sprite2D.flip_h = true;
	$OutPosition.position = ($OutPosition.position as Vector2).abs() * Vector2(-1.0, 1.0);


func point_right() -> void:
	$Sprite2D.flip_h = false;
	$OutPosition.position = ($OutPosition.position as Vector2).abs() * Vector2(1.0, 1.0);
