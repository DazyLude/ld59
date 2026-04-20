extends Module


var max_charge : int = 10.0;
var charge_progress : int;

const default_modulate = Color("ffffff2a")
var flicker_progress : float = 0.0;


func _ready() -> void:
	super._ready();
	create_energy_bar(0.0, max_charge);


func _process(delta: float) -> void:
	$Protecc.visible = current_hp > 0;
	$Protecc2.visible = current_hp > 0;
	
	flicker_progress += delta;
	if flicker_progress >= 2.0:
		$Protecc.modulate = default_modulate * Color(1, 1, 1, randf_range(0.3, 1.7));
		$Protecc2.modulate = default_modulate * Color(1, 1, 1, randf_range(0.3, 1.7));
		flicker_progress = randf_range(0.2, 1.8);


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	return true;


func receive_input(_orb: Orb, _from: Vector2i) -> void:
	charge_progress += 1;
	if charge_progress == max_charge:
		charge_progress = 0;
		current_hp = max_hp;
	
	if energy_bar != null:
		energy_bar.show();
		energy_bar.value = charge_progress;
