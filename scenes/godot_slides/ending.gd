extends Control


func _ready() -> void:
	spawn_player_machine();
	$Button.pressed.connect(GameState.go_to_menu);


func spawn_player_machine() -> void:
	var player_machine := Machine.load_from_dictionary(GameState.player_template);
	player_machine.position = GameState.left_machine_offset
	add_child(player_machine)
	GameState.machine_left = player_machine;
