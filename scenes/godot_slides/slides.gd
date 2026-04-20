extends Control


signal finished;


@export var slides : Array[Control] = [];
@export var transition_delay : Dictionary[int, float] = {};
@export var per_slide_music : Array[BgmPlayer.SoundID] = [];
@export var one_offs : Array[OneOffSpecs];


var current_slide : int = -1;
var just_entered : bool = true;
var inactivity_time : float = 0.0;
const inactivity_threshold := 10.0;
const inactivity_attack := 2.0;


func _ready() -> void:
	update_visibility();
	$Label.modulate = Color(1.0, 1.0, 1.0, 0.0);
	
	for i in slides.size() - per_slide_music.size():
		per_slide_music.push_back(BgmPlayer.SoundID.None);
	
	next();


func _process(delta: float) -> void:
	if just_entered:
		inactivity_time += delta;
		
		if inactivity_time >= inactivity_threshold:
			var p := minf((inactivity_time - inactivity_threshold) / inactivity_attack, 1.0);
			$Label.modulate = Color(1.0, 1.0, 1.0, p);


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton;
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			next();
	
	if event.is_action_pressed(&"continue"):
		next();


func update_visibility() -> void:
	for slide_idx in slides.size():
		var slide = slides[slide_idx];
		slide.visible = current_slide == slide_idx;


func next() -> void:
	just_entered = false;
	current_slide += 1;
	
	if current_slide >= slides.size():
		finished.emit()
	else:
		if current_slide in transition_delay:
			var delay = transition_delay[current_slide]
			get_tree().create_timer(delay).timeout.connect(update_visibility);
		else:
			update_visibility();
		var new_track := per_slide_music[current_slide];
		if new_track != BgmPlayer.SoundID.None:
			BgmPlayer.change_track(new_track)
		play_one_offs();


func play_one_offs() -> void:
	for one_off in one_offs:
		if current_slide == one_off.slide:
			BgmPlayer.play_one_off(one_off.sound);
