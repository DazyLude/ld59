extends Node2D


var reversed : bool :
	set(v):
		reversed = v;
		for node in node_starting_positions:
			node.flipv = reversed;


var grid_ref : Node2D :
	set(v):
		if grid_ref != null:
			node_starting_positions.erase(grid_ref);
		if v != null:
			node_starting_positions[v] = v.position;
		grid_ref = v;


var random_phase = randf_range(0.0, 2 * PI);
var breath_speed = PI / 4.0
var breath_amplitude = 10.0;


var textures := {
	"default": [
		preload("res://assets/robots/protag/body.png"),
		preload("res://assets/robots/protag/leg1.png"),
		preload("res://assets/robots/protag/leg2.png")
	],
	"default_victory": [
		preload("res://assets/robots/protag/body s venochkom.png"),
		preload("res://assets/robots/protag/leg1.png"),
		preload("res://assets/robots/protag/leg2.png")
	],
	"beholder": [
		preload("res://assets/robots/beholder/enemy4.png"),
		null, null,
	],
	"broken": [
		preload("res://assets/robots/borken/body.png"),
		preload("res://assets/robots/borken/leg1.png"),
		preload("res://assets/robots/borken/leg2.png"),
	],
	"broken2": [
		preload("res://assets/robots/borken_model2/body.png"),
		preload("res://assets/robots/borken_model2/leg1.png"),
		preload("res://assets/robots/borken_model2/leg2.png"),
	],
	"overgrown": [
		preload("res://assets/robots/overgrowth/body.png"),
		preload("res://assets/robots/overgrowth/leg1.png"),
		preload("res://assets/robots/overgrowth/leg2.png"),
	],
	"wall": [
		preload("res://assets/robots/wall/wall.png"),
		null,
		null,
	]
}



@onready
var node_starting_positions : Dictionary = {
	$BackLegSprite: $BackLegSprite.position,
	$BodySprite: $BodySprite.position,
	$LegSprite: $LegSprite.position
}

var breath_progress : float = 0.0;


func _ready() -> void:
	scale = Vector2(GameState.gameplay_scale, GameState.gameplay_scale)
	for node in node_starting_positions:
		node.flip_h = reversed;


func _process(delta: float) -> void:
	breath_progress += delta;
	var offset := Vector2(0.0, sin(breath_progress * breath_speed + random_phase) * breath_amplitude);
	
	if grid_ref != null:
		grid_ref.position = node_starting_positions[grid_ref] + offset * Vector2(GameState.gameplay_scale, GameState.gameplay_scale);
	$BodySprite.position = node_starting_positions[$BodySprite] + offset;


func set_textures(pack_name: String = "default") -> void:
	var pack : Array = textures[pack_name];
	$BodySprite.texture = pack[0];
	$LegSprite.texture = pack[1];
	$BackLegSprite.texture = pack[2];
	
	if pack_name == "wall":
		breath_amplitude = 0.0;
