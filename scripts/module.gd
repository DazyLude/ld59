extends Node2D
class_name Module


signal spawn_output(output: Orb);
signal destroyed;


@export var max_hp : float = 100.0;
@export var outputs : Array[Vector2i] = [];
@export var inputs : Array[Vector2i] = [];


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


func _physics_process(_delta: float) -> void:
	pass;


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
	
	if current_hp <= 0:
		destroyed.emit();


func point_left() -> void:
	pass;


func point_right() -> void:
	pass;


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
