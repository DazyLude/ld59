extends Module


var progress : float;

func _physics_process(delta: float) -> void:
	progress += delta;
	if progress >= 1.0:
		progress -= 1.0;
		spawn_output.emit(Orb.new())


func _ready() -> void:
	sprite = self.get_child(0);
