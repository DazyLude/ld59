extends Control


@export var slides : Array[Node2D] = [];
var current_slide_idx : int = 0;


func _ready() -> void:
	$HBoxContainer/back.pressed.connect(back_to_menu)
	$HBoxContainer/prev.pressed.connect(previous_slide)
	$HBoxContainer/next.pressed.connect(next_slide)
	
	update_slide()


func previous_slide() -> void:
	@warning_ignore("narrowing_conversion")
	current_slide_idx = move_toward(current_slide_idx, 0, 1);
	update_slide()


func next_slide() -> void:
	@warning_ignore("narrowing_conversion")
	current_slide_idx = move_toward(current_slide_idx, slides.size() - 1, 1);
	update_slide()


func update_slide() -> void:
	for slide in slides:
		slide.hide();
	
	$HBoxContainer/Panel/Label.text = "%d / %d" % [current_slide_idx + 1, slides.size()]
	slides[current_slide_idx].show();


func back_to_menu() -> void:
	GameState.go_to_menu()
