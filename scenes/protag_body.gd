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
		grid_ref.position = node_starting_positions[grid_ref] + offset;
	$BodySprite.position = node_starting_positions[$BodySprite] + offset;
