extends Node
class_name _MachineLibraryClass


var machines : Dictionary[String, String] = {
	"starting_machine": '{"args":["s:modules",[{"args":["s:module_name","s:generator","s:position",{"args":[0,0],"type":"Vector2i"}],"type":"Dictionary"},{"args":["s:module_name","s:peashooter","s:position",{"args":[2,0],"type":"Vector2i"},"s:module_data",{"args":["s:hp","f:10.0"],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[1,0],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:0","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"}],"s:inventory",[]],"type":"Dictionary"}',
	"overengineered": '{"args":["s:modules",[{"args":["s:module_name","s:generator","s:position",{"args":[0,0],"type":"Vector2i"},"s:module_data",{"args":["s:hp","f:10.0"],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:peashooter","s:position",{"args":[2,0],"type":"Vector2i"},"s:module_data",{"args":["s:hp","f:10.0"],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:splitter","s:position",{"args":[0,-1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:3","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:splitter","s:position",{"args":[1,-1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:0","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:merger","s:position",{"args":[0,-2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[1,-2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[-1,-2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:2","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:merger","s:position",{"args":[-1,-1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:merger","s:position",{"args":[-1,0],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:merger","s:position",{"args":[-1,1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[0,1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:1","s:rot","i:1","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[-1,2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:1","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[0,2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:0","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[1,2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:0","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[2,2],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:0","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[2,1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:2","s:rot","i:3","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:tube","s:position",{"args":[1,1],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:1","s:rot","i:2","s:r",false],"type":"Dictionary"}],"type":"Dictionary"},{"args":["s:module_name","s:merger","s:position",{"args":[1,0],"type":"Vector2i"},"s:module_data",{"args":["s:t","i:3","s:rot","i:2","s:r",false],"type":"Dictionary"}],"type":"Dictionary"}],"s:inventory",[]],"type":"Dictionary"}',
}


var body_variants : Dictionary[String, PackedScene] = {
	"default": preload("res://scenes/crazy_machine.tscn"),
}


func load_machine(machine_name: String) -> Machine:
	var json := JSON.new()
	var error := json.parse(machines[machine_name])
	if error == OK:
		var data = JSON.to_native(json.data);
		if typeof(data) == TYPE_DICTIONARY:
			var machine = Machine.load_from_dictionary(data);
			if machine != null:
				return machine;
	
	return null;
