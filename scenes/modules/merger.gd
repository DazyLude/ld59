extends Module


const n := Vector2i( 0.0, -1.0);
const e := Vector2i( 1.0,  0.0);
const w := Vector2i(-1.0,  0.0);
const s := Vector2i( 0.0,  1.0);
const pos_mult := Vector2(48.0, 48.0);

const rot_outputs : Array[Vector2i] = [
	w, n, e, s
]

const type_rot_inputs : Array[Array] = [
	[n, s], [n, e], [s, e], [n, e, s], # rot0
	[e, w], [e, s], [w, s], [e, s, w], # rot1
	[s, n], [s, w], [n, w], [s, w, n], # rot2
	[w, e], [w, n], [e, n], [w, n, e], # rot3
]

const texture_atlas_position_type_mapping = [
	tas * Vector2(1, 8), tas * Vector2(2, 9), tas * Vector2(3, 9), tas * Vector2(1, 11), # rot0
	tas * Vector2(2, 8), tas * Vector2(0, 9), tas * Vector2(1, 9), tas * Vector2(3, 11), # rot1
	tas * Vector2(0, 8), tas * Vector2(3, 10), tas * Vector2(2, 10), tas * Vector2(0, 11), # rot2
	tas * Vector2(3, 8), tas * Vector2(1, 10), tas * Vector2(0, 10), tas * Vector2(2, 11), # rot3
]
const tas = Vector2(64, 64);


var rot : int = 0:
	set(v):
		rot = wrapi(v, 0, 4);
		update_inputs_outputs();
		if is_node_ready():
			update_type_visuals();


@export_enum(
	"none:-1",
	"t:0",
	"t-side-cw:1",
	"t-side-ccw:1",
	"+:2",
) var type : int = -1 :
	set(v):
		if v < -1 or v >= 4:
			push_error("wrong splitter type");
			return;
		type = v;
		
		update_inputs_outputs();
		if is_node_ready():
			update_type_visuals();


const MAX_ORBS := 3;
const PIPE_LENGTH := 2.1;

var holding_orbs : Array[Orb] = [];
var per_orb_progress : Array[float] = [];

var orb_n : int = 0;
var per_orb_source : Array[Vector2i] = [];

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


func update_inputs_outputs() -> void:
	if type != -1:
		inputs = Array(type_rot_inputs[type + rot * 4], TYPE_VECTOR2I, &'', null);
		outputs = [rot_outputs[rot]];
	else:
		inputs = []
		outputs = []


func can_receive_input(_orb: Orb, _from: Vector2i) -> bool:
	return holding_orbs.size() < MAX_ORBS;


func receive_input(orb: Orb, from: Vector2i) -> void:
	holding_orbs.push_front(orb);
	per_orb_progress.push_front(0.0);
	per_orb_source.push_front(from);
	orb_n = wrapi(orb_n + 1, 0, outputs.size());
	
	var orb_node := get_free_orb_node();
	orb_nodes.push_front(orb_node);
	
	update_orb_position(0, 0.0);


func release_frontmost_orb() -> void:
	var orb : Orb = holding_orbs.pop_back();
	spawn_output.emit(orb, 0);
	per_orb_progress.pop_back();
	per_orb_source.pop_back();
	
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
		update_orb_position(idx, progress / PIPE_LENGTH);


func update_orb_position(orb_idx: int, progress: float) -> void:
	var node := orb_nodes[orb_idx];
	
	if type == -1:
		return;
	
	var rev_mult := Vector2(-1.0, 1.0) if reversed else Vector2(1.0, 1.0);
	
	if progress < 0.5:
		var start := Vector2(per_orb_source[orb_idx]) * pos_mult * rev_mult * GameState.gameplay_scale;
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
		texture_atlas_position_type_mapping[type + rot * 4],
		tas
	);
	icon = $TubeBody.texture
	update_input_output_display();


func point_left() -> void:
	reversed = true;


func point_right() -> void:
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
