extends Module


var progress : float;


func _physics_process(delta: float) -> void:
	progress += delta;
	if progress >= 1.0:
		progress -= 1.0;
		spawn_output.emit(Orb.new(), -1)


func set_scale_modifier(scmod: float) -> void:
	$Sprite2D.scale = Vector2(scmod, scmod);
	$Area2D/CollisionShape2D.shape.size = ModuleGrid.CELL_SIZE  * scmod;
	
	if hp_bar:
		hp_bar.scale = Vector2(scmod, scmod);
		hp_bar.position += Vector2(ceil(scmod * 32), -ceil(scmod * 32));
