extends Module


const n := Vector2i( 0.0, -1.0);
const e := Vector2i( 1.0,  0.0);
const w := Vector2i(-1.0,  0.0);
const s := Vector2i( 0.0,  1.0);

const rot_inputs : Array[Vector2i] = [
	w, n, e, s
]

const rot_outputs : Array[Array] = [
	[n, e, s], # rot0
	[e, s, w], # rot1
	[s, w, n], # rot2
	[w, n, e], # rot3
]


var rot : int = 0:
	set(v):
		rot = wrapi(v, 0, 4);
		update_inputs_outputs();


func _ready() -> void:
	super._ready();
	update_inputs_outputs();


func can_receive_input(_orb: Orb, from: Vector2i) -> bool:
	return from == inputs[0];


func receive_input(_orb: Orb, _from: Vector2i) -> void:
	for i in 3:
		spawn_output.emit(_orb, i)


func update_inputs_outputs() -> void:
	inputs = [rot_inputs[rot]];
	outputs = Array(rot_outputs[rot], TYPE_VECTOR2I, &'', null);
	update_input_output_display();


func get_data() -> Dictionary:
	return {
		"rot": rot,
		"hp": current_hp,
		"max_hp": max_hp,
	}


func apply_data(d: Dictionary) -> void:
	current_hp = d.hp;
	rot = d.rot;
	max_hp = d.max_hp;
