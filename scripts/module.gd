extends Node2D
class_name Module


signal spawn_output(output: Orb, idx: int);
signal destroyed;


@export var max_hp : float = 100.0;
@export var outputs : Array[Vector2i] = [];
@export var inputs : Array[Vector2i] = [];
@export var hp_bar : ProgressBar = null;

@export_category("tooltips and bookkeeping")
@export var module_name : String = "";
@export_placeholder("{name}_desc") var description : String = "":
	get:
		if description == "" and module_name != "":
			return "%s_desc" % module_name;
		return description

var current_hp : float = 100.0;

@export var hitbox : Area2D = null:
	set(v):
		if hitbox != null:
			disconnect_hitbox(hitbox);
		if v != null:
			connect_hitbox(v);
		
		v = hitbox;


func _ready() -> void:
	if hitbox != null:
		connect_hitbox(hitbox);
		
	if hp_bar == null:
		create_hp_bar();


func _physics_process(_delta: float) -> void:
	pass;


func create_hp_bar():
	hp_bar = ProgressBar.new();
	
	hp_bar.show_percentage = false;
	hp_bar.size = Vector2(128, 12);
	hp_bar.position = self.get_child(0).position + Vector2(-64, 64);
	hp_bar.get_theme_stylebox("fill").bg_color = Color.GREEN;
	
	hp_bar.visible = false;
	self.add_child(hp_bar);


func connect_hitbox(hb: Area2D) -> void:
	hb.owner = self;


func disconnect_hitbox(hb: Area2D) -> void:
	hb.queue_free();


func can_receive_input(_orb: Orb) -> bool:
	return false;


func receive_input(_orb: Orb) -> void:
	pass;


func receive_damage(damage: float) -> void:
	current_hp -= damage;
	spawn_notification("-%d(/%d)" % [damage, current_hp], 0.5);
	
	if hp_bar:
		hp_bar.visible = true;
		hp_bar.value = current_hp;
		hp_bar.get_theme_stylebox("fill").bg_color = Color.RED.lerp(Color.GREEN, current_hp / max_hp);
	
	if current_hp <= 0:
		destroyed.emit();


func point_left() -> void:
	pass;


func point_right() -> void:
	pass;


func set_scale_modifier(scale_modifier: float) -> void:
	scale = Vector2(scale_modifier, scale_modifier);


func spawn_notification(text: String, lifetime: float) -> void:
	var tween := create_tween();
	
	var noto := Label.new();
	var starting_position := Vector2();
	var speed := Vector2(0.0, -50.0);
	
	noto.position = starting_position;
	noto.text = text;
	
	add_child(noto);
	tween.tween_property(noto, ^"position", starting_position + speed * lifetime, lifetime);
	tween.tween_callback(noto.queue_free);


func get_data() -> Dictionary:
	return {};


func apply_data(_d: Dictionary) -> void:
	pass;
