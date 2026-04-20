extends Module


const n := Vector2i( 0.0, -1.0);
const e := Vector2i( 1.0,  0.0);
const w := Vector2i(-1.0,  0.0);
const s := Vector2i( 0.0,  1.0);
const pos_mult := Vector2(48.0, 48.0);

const type_inputs : Array[Vector2i] = [
	w, n, e, s, # t0 r0-4
	w, n, e, s, # t1 r0-4
	w, n, e, s, # t2 r0-4
]

const type_outputs : Array[Vector2i] = [
	e, s, w, n, # t0 r0-4
	s, w, n, e, # t1 r0-4
	n, e, s, w, # t2 r0-4
]

const texture_atlas_position_type_mapping = [
	tas * Vector2(3, 4), tas * Vector2(1, 4), # t0 r0-1
	tas * Vector2(2, 4), tas * Vector2(0, 4), # t0 r2-3
	tas * Vector2(1, 2), tas * Vector2(3, 3), # t1 r0-1
	tas * Vector2(0, 3), tas * Vector2(2, 2), # t1 r2-3
	tas * Vector2(1, 3), tas * Vector2(2, 3), # t2 r0-1
	tas * Vector2(0, 2), tas * Vector2(3, 2), # t2 r2-3
]
const tas = Vector2(64, 64);


@export_enum(
	"none:-1",
	"straight:0",
	"corner_cw:1",
	"corner_ccw:2",
) var type : int = -1 :
	set(v):
		if v < -1 or v >= 3:
			push_error("wrong tube type");
			return;
		type = v;
		
		update_inputs_outputs();
		if is_node_ready():
			update_type_visuals();


var rot : int = 0:
	set(v):
		rot = wrapi(v, 0, 4);
		update_inputs_outputs();
		if is_node_ready():
			update_type_visuals();


const MAX_ORBS := 3;
const PIPE_LENGTH := 2.1;

var holding_orbs : Array[Orb] = [];
var per_orb_progress : Array[float] = [];

var orb_nodes : Array[OrbRenderer] = [];
var free_orb_nodes : Array[OrbRenderer] = [];

var reversed : bool = false;


func _ready() -> void:
	super._ready();
	update_type_visuals();
	hitbox.set_deferred("monitorable", GameState.is_editing);
	hitbox.set_deferred("monitoring", GameState.is_editing);


func _physics_process(delta: float) -> void:
	super._physics_process(delta);
	for idx in per_orb_progress.size():
		per_orb_progress[idx] += delta;
		if per_orb_progress[idx] >= PIPE_LENGTH:
			release_frontmost_orb.call_deferred()
	
	update_orb_positions();


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	return holding_orbs.size() < MAX_ORBS;


func receive_input(orb: Orb, _from: Vector2i) -> void:
	holding_orbs.push_front(orb);
	per_orb_progress.push_front(0.0);
	
	var orb_node := get_free_orb_node();
	orb_nodes.push_front(orb_node);
	
	update_orb_position(orb_node, 0.0);


func release_frontmost_orb() -> void:
	var orb : Orb = holding_orbs.pop_back();
	spawn_output.emit(orb, 0);
	
	per_orb_progress.pop_back();
	var node : OrbRenderer = orb_nodes.pop_back();
	free_orb_node(node);


func get_free_orb_node() -> OrbRenderer:
	if free_orb_nodes.is_empty():
		var orb_node : OrbRenderer = preload("res://scenes/entities/orb.tscn").instantiate();
		add_child(orb_node);
		return orb_node;
	else:
		var orb_node : OrbRenderer = free_orb_nodes.pop_back();
		orb_node.show();
		return orb_node;


func free_orb_node(node: OrbRenderer) -> void:
	free_orb_nodes.push_back(node);
	node.hide();


func update_orb_positions() -> void:
	for idx in per_orb_progress.size():
		var progress := per_orb_progress[idx];
		var node := orb_nodes[idx];
		update_orb_position(node, progress / PIPE_LENGTH);


func update_orb_position(node: OrbRenderer, progress: float) -> void:
	if type == -1:
		return;
	
	var rev_mult := Vector2(-1.0, 1.0) if reversed else Vector2(1.0, 1.0);
	
	if progress < 0.5:
		var start := Vector2(inputs[0]) * pos_mult * rev_mult * GameState.gameplay_scale;
		node.position = lerp(start, Vector2(), progress * 2.0)
	else:
		var end := Vector2(outputs[0]) * pos_mult * rev_mult * GameState.gameplay_scale;
		node.position = lerp(Vector2(), end, progress * 2.0 - 1.0)


func update_type_visuals() -> void:
	if type == -1:
		$TubeBody.hide();
		return;
	
	$TubeBody.show();
	
	($TubeBody.texture as AtlasTexture).region = Rect2(
		texture_atlas_position_type_mapping[type * 4 + rot],
		tas
	);
	icon = $TubeBody.texture
	update_input_output_display();


func update_inputs_outputs():
	if type != -1:
		inputs = [type_inputs[type * 4 + rot]]
		outputs = [type_outputs[type * 4 + rot]]
	else:
		inputs = []
		outputs = []


func point_left() -> void:
	$TubeBody.flip_h = true;
	reversed = true;


func point_right() -> void:
	$TubeBody.flip_h = false;
	reversed = false;


func get_data() -> Dictionary:
	return {
		"t": type,
		"rot": rot,
		"r": reversed,
	}


func apply_data(d: Dictionary) -> void:
	type = d.t;
	rot = d.rot;
	reversed = d.r;
