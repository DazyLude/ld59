extends Module


const n := Vector2i( 0.0, -1.0);
const e := Vector2i( 1.0,  0.0);
const w := Vector2i(-1.0,  0.0);
const s := Vector2i( 0.0,  1.0);
const pos_mult := Vector2(64.0, 64.0);

const type_inputs : Array[Vector2i] = [
	w, e, # we
	n, s, # ns
	n, n, # nn
	s, s, # ss
	w, w, # ww
	e, e, # ee
]

const type_outputs : Array[Vector2i] = [
	e, w, # ew
	s, n, # sn
	e, w, # ew
	e, w, # ew
	n, s, # ns
	n, s, # ns
]

const texture_atlas_position_type_mapping = [
	Vector2(0, 128 * 1), Vector2(0, 128 * 1), # 11
	Vector2(0, 128 * 2), Vector2(0, 128 * 2), # 22
	Vector2(0, 128 * 3), Vector2(0, 128 * 4), # 34
	Vector2(0, 128 * 5), Vector2(0, 128 * 6), # 56
	Vector2(0, 128 * 4), Vector2(0, 128 * 6), # 46
	Vector2(0, 128 * 3), Vector2(0, 128 * 5), # 35
]
const texture_atlas_size = Vector2(128, 128);


@export_enum(
	"none:-1",
	"straight_we:0", "straight_ew:1",
	"straight_ns:2", "straight_sn:3",
	"corner_ne:4", "corner_nw:5",
	"corner_se:6", "corner_sw:7",
	"corner_wn:8", "corner_ws:9",
	"corner_en:10", "corner_es:11",
) var type : int = -1 :
	set(v):
		if v < -1 or v >= 12:
			push_error("wrong tube type");
			return;
		
		if v != -1:
			inputs = [type_inputs[v]]
			outputs = [type_outputs[v]]
		else:
			inputs = []
			outputs = []
		
		type = v;
		
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


func _physics_process(delta: float) -> void:
	super._physics_process(delta);
	for idx in per_orb_progress.size():
		per_orb_progress[idx] += delta;
		if per_orb_progress[idx] >= PIPE_LENGTH:
			release_frontmost_orb()
	
	update_orb_positions();


func can_receive_input(_orb: Orb) -> bool:
	return holding_orbs.size() < MAX_ORBS;


func receive_input(orb: Orb) -> void:
	holding_orbs.push_front(orb);
	per_orb_progress.push_front(0.0);
	
	var orb_node := get_free_orb_node();
	orb_nodes.push_front(orb_node);
	
	update_orb_position(orb_node, 0.0);


func release_frontmost_orb() -> void:
	var orb : Orb = holding_orbs.pop_back();
	spawn_output.emit(orb);
	
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
	
	if reversed:
		progress = 1.0 - progress;
	
	if progress < 0.5:
		node.position = lerp(Vector2(inputs[0]) * pos_mult, Vector2(), progress * 2.0)
	else:
		node.position = lerp(Vector2(), Vector2(outputs[0]) * pos_mult, progress * 2.0 - 1.0)


func update_type_visuals() -> void:
	if type == -1:
		$TubeConnectors.hide();
		$TubeBody.hide();
		return;
	
	$TubeConnectors.show();
	$TubeBody.show();
	
	($TubeBody.texture as AtlasTexture).region = Rect2(
		texture_atlas_position_type_mapping[type],
		texture_atlas_size
	);


func point_left() -> void:
	reversed = true;


func point_right() -> void:
	reversed = false;
