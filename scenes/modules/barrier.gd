extends Module


var max_charge : int = 15.0;
var charge_progress : int = 0.0;
var barrier_health = 1000.0;
var max_active_time := 5.0;
var active_time := 0.0;
var active := false;

const default_modulate = Color("ffffff2a")
var flicker_progress : float = 0.0;

func _ready() -> void:
	super._ready();
	create_energy_bar(0.0, max_charge);


func _process(delta: float) -> void:
	active_time -= delta;
	
	if active_time <= 0 and active:
		deactivate();
	
	$Protecc.visible = active;
	if active:
		var p = (active_time + 1.0);
		$Protecc.scale = Vector2(p, p)
		
		flicker_progress += delta;
		if flicker_progress >= 2.0:
			$Protecc.modulate = default_modulate * Color(1, 1, 1, randf_range(0.3, 1.7));
			flicker_progress = randf_range(0.2, 1.8);


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	return charge_progress < max_charge and current_hp > 0;


func receive_damage(damage: float) -> void:
	super.receive_damage(damage);
	BgmPlayer.play_one_off(BgmPlayer.SoundID.FXBarrierHit)


func receive_input(_orb: Orb, _from: Vector2i) -> void:
	charge_progress += 1;
	
	if charge_progress >= max_charge:
		spawn_notification("Barrier ready! Click to activate.", 1.0);
	
	if energy_bar != null:
		energy_bar.show();
		energy_bar.value = charge_progress;


func can_activate() -> bool:
	return charge_progress >= max_charge and current_hp > 0;


var hp_cache : float;
func activate() -> void:
	if owner is ModuleGrid:
		BgmPlayer.play_one_off(BgmPlayer.SoundID.FXBarrierActive)
		charge_progress = 0;
		active = true;
		var grid := owner as ModuleGrid;
		grid.barrier_active = self;
		hp_cache = current_hp; 
		current_hp = barrier_health;
		active_time = max_active_time;


func deactivate() -> void:
	if owner is ModuleGrid:
		var grid := owner as ModuleGrid;
		if grid.barrier_active == self:
			grid.barrier_active = null;
		
		active = false;
		current_hp = hp_cache;
		active_time = 0.0;
		


func get_data() -> Dictionary:
	var data := super.get_data();
	if active:
		data.hp = hp_cache;
	return data;
