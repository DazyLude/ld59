extends Control


func _ready() -> void:
	BgmPlayer.change_track(BgmPlayer.SoundID.MusicDefault)
	
	$VolumeControl/HSlider.value_changed.connect(update_master_volume);
	var master_idx := AudioServer.get_bus_index(&"Master");
	$VolumeControl/HSlider.value = AudioServer.get_bus_volume_linear(master_idx) * 100.0;
	
	$VBoxContainer/Button3.visible = GameState.game_finished;
	
	$VBoxContainer/Button.pressed.connect(GameState.load_new_game);
	$VBoxContainer/Button2.pressed.connect(GameState.load_tutorial);
	$VBoxContainer/Button3.pressed.connect(GameState.load_creative);


func update_master_volume(v: float) -> void:
	var master_idx := AudioServer.get_bus_index(&"Master");
	AudioServer.set_bus_volume_linear(master_idx, v / 100.0)
