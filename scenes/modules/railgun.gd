extends Module


@export var pea_output : Marker2D;


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	if current_hp <= 0:
		return false;
	
	return true;


func receive_input(_orb: Orb, _from: Vector2i) -> void:
	if GameState.is_editing:
		return;
	
	var target : Vector2i = owner.owner.targeting_strategy;
	var target_global_coords = GameState.get_other_grid_location(self, target);
	var angle = pea_output.global_position.angle_to_point(target_global_coords);
	#$Body.rotation = angle;
	
	var pea : Projectile = preload("res://scenes/entities/bullet.tscn").instantiate();
	
	pea.rotate(angle);
	pea.position = pea_output.position.rotated($Body.rotation);
	pea.direction = Vector2(1.0, 0.0).rotated(angle);
	
	
	BgmPlayer.play_one_off(BgmPlayer.SoundID.FXRailShoot);
	GameState.shoot_projectile(pea, self, to_global(pea.position));


func point_left() -> void:
	$Base.flip_h = true;
	$Body.flip_h = true;
	$Body.offset = $Body.offset.abs() * Vector2(-1.0, 1.0);
	pea_output.position = (pea_output.position as Vector2).abs() * Vector2(-1.0, 1.0);


func point_right() -> void:
	$Base.flip_h = false;
	$Body.flip_h = false;
	$Body.offset = $Body.offset.abs() * Vector2(+1.0, 1.0);
	pea_output.position = (pea_output.position as Vector2).abs() * Vector2(1.0, 1.0);
