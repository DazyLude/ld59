extends Node2D
class_name Module


signal spawn_output(output: Orb, idx: int);
signal destroyed;


@export var max_hp : float = 100.0;
@export var outputs : Array[Vector2i] = [];
@export var inputs : Array[Vector2i] = [];
@export var icon : Texture2D;

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
	
	if icon == null:
		var textures := get_children().filter(func(c): return c is Sprite2D).map(func(s): return s.texture)
		if textures.size() == 1:
			icon = textures[0];
		elif textures.size() > 1:
			icon = textures[0];


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


func set_scale_modifier(scale_modifier: float) -> void:
	scale = Vector2(scale_modifier, scale_modifier);
	
	if hitbox != null:
		var so := hitbox.get_shape_owners();
		if so.size() > 0:
			var shape := hitbox.shape_owner_get_shape(so[0], 0);
			if shape is RectangleShape2D and shape.size.x == shape.size.y:
				shape.size = ModuleGrid.CELL_SIZE * scale_modifier;


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
	if current_hp <= max_hp:
		return {"hp" : current_hp}
	return {};


func apply_data(d: Dictionary) -> void:
	if d.is_empty():
		return;
	
	if d.has("hp"):
		current_hp = d.hp;


func make_copy() -> Module:
	var module := ModuleLibrary.get_module(module_name);
	module.apply_data(get_data());
	return module;


func turn_shadow() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.5);


func turn_normal() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0);
