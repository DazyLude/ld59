extends Node2D
class_name Module


signal spawn_output(output: Orb, idx: int);
signal destroyed;


@export var max_hp : float = 10.0;
@export var outputs : Array[Vector2i] = [];
@export var inputs : Array[Vector2i] = [];
@export var icon : Texture2D;
@export var hp_bar : ProgressBar = null;
@export var energy_bar : ProgressBar = null;

@export var input_sprites : Dictionary[Vector2i, Sprite2D];
@export var output_sprites : Dictionary[Vector2i, Sprite2D];

@export_category("tooltips and bookkeeping")
@export var module_name : String = "";
@export_placeholder("{name}_desc") var description : String = "":
	get:
		if description == "" and module_name != "":
			return "%s_desc" % module_name;
		return description


var current_hp : float = max_hp;

@export var hitbox : Area2D = null:
	set(v):
		if hitbox != null:
			disconnect_hitbox(hitbox);
		if v != null:
			connect_hitbox(v);
		
		hitbox = v;


func _ready() -> void:
	if hitbox != null:
		connect_hitbox(hitbox);
	else:
		var areas := get_children().filter(func(c): return c is Area2D)
		if areas.size() > 0:
			hitbox = areas[0];
	
	if GameState.is_editing:
		if input_sprites.is_empty():
			var default_textures := {
				Vector2i(1, 0): preload("res://assets/module_visuals/inputs_outputs/input_e.tres"),
				Vector2i(0, -1): preload("res://assets/module_visuals/inputs_outputs/input_n.tres"),
				Vector2i(0, 1): preload("res://assets/module_visuals/inputs_outputs/input_s.tres"),
				Vector2i(-1, 0): preload("res://assets/module_visuals/inputs_outputs/input_w.tres"),
			}
			for input in default_textures:
				var sprite := Sprite2D.new();
				sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.5);
				sprite.texture = default_textures[input];
				add_child(sprite);
				input_sprites[input] = sprite;
				sprite.visible = input in inputs;
		
		if output_sprites.is_empty():
			var default_textures := {
				Vector2i(1, 0): preload("res://assets/module_visuals/inputs_outputs/output_e.tres"),
				Vector2i(0, -1): preload("res://assets/module_visuals/inputs_outputs/output_n.tres"),
				Vector2i(0, 1): preload("res://assets/module_visuals/inputs_outputs/output_s.tres"),
				Vector2i(-1, 0): preload("res://assets/module_visuals/inputs_outputs/output_w.tres"),
			}
			for output in default_textures:
				var sprite := Sprite2D.new();
				sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.5);
				sprite.texture = default_textures[output];
				add_child(sprite);
				output_sprites[output] = sprite;
				sprite.visible = output in outputs;
	
	if icon == null:
		var textures := get_children().filter(func(c): return c is Sprite2D).map(func(s): return s.texture)
		if textures.size() == 1:
			icon = textures[0];
		elif textures.size() > 1:
			icon = textures[0];
	
	if hp_bar == null:
		create_hp_bar();
	
	current_hp = max_hp;


func update_input_output_display() -> void:
	for input in input_sprites:
		input_sprites[input].visible = input in inputs;
	for output in output_sprites:
		output_sprites[output].visible = output in outputs;


func _physics_process(_delta: float) -> void:
	pass;


func create_hp_bar():
	hp_bar = ProgressBar.new();
	hp_bar.show_percentage = false;
	hp_bar.value = current_hp;
	hp_bar.max_value = max_hp;
	
	var width = ModuleGrid.CELL_SIZE[0];
	hp_bar.size = Vector2(width, 8);
	hp_bar.position = Vector2(-width / 2, width / 2 - 6);
	
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.LIME_GREEN;
	hp_bar.add_theme_stylebox_override("fill", stylebox);
	
	hp_bar.visible = false;
	self.add_child(hp_bar);


func create_energy_bar(current: float, max: float):
	energy_bar = ProgressBar.new();
	energy_bar.show_percentage = false;
	energy_bar.value = current;
	energy_bar.max_value = max;
	
	var width = ModuleGrid.CELL_SIZE[0];
	energy_bar.size = Vector2(width, 8);
	energy_bar.position = Vector2(-width / 2, width / 2 - 14);
	
	var blue_stylebox = StyleBoxFlat.new()
	blue_stylebox.bg_color = Color.ROYAL_BLUE;
	energy_bar.add_theme_stylebox_override("fill", blue_stylebox);
	
	energy_bar.visible = false;
	self.add_child(energy_bar);


func connect_hitbox(hb: Area2D) -> void:
	hb.owner = self;


func disconnect_hitbox(hb: Area2D) -> void:
	hb.queue_free();


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	return false;


func receive_input(_orb: Orb, _from: Vector2i) -> void:
	pass;


func can_activate() -> bool:
	return false;


func activate() -> void:
	pass;


func receive_damage(damage: float) -> void:
	if owner is ModuleGrid:
		var protector := (owner as ModuleGrid).get_protector(self)
		if protector != null:
			protector.receive_damage(damage);
			return;
	
	current_hp -= damage;
	
	if hp_bar:
		hp_bar.visible = true;
		hp_bar.value = current_hp;
	
	if current_hp <= 0:
		destroyed.emit();
		_on_destroyed();


func _on_destroyed() -> void:
	turn_shadow();
	hitbox.set_deferred("monitorable", false);
	hitbox.set_deferred("monitoring", false);


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
				shape.size = ModuleGrid.CELL_SIZE;


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
	return {
		"hp" : current_hp,
		"max_hp": max_hp,
	}


func apply_data(d: Dictionary) -> void:
	max_hp = d.get("max_hp", max_hp)
	current_hp = minf(d.get("hp", max_hp), max_hp);


func make_copy() -> Module:
	var module := ModuleLibrary.get_module(module_name);
	module.apply_data(get_data());
	return module;


func turn_shadow() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.5);


func turn_normal() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0);
