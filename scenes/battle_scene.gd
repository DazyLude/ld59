extends Node2D


func _ready() -> void:
	var machine_pckd = preload("res://scenes/crazy_machine.tscn");
	
	var machine1 : Machine = machine_pckd.instantiate()
	GameState.add_machine(machine1)
	machine1.position = Vector2(50.0, 300.0)
	add_child(machine1)
	
	var machine2 : Machine = machine_pckd.instantiate();
	GameState.add_machine(machine_pckd.instantiate())
	machine2.position = Vector2(1000.0, 300.0)
	add_child(machine2)
	machine2.grid.reversed = true;
	
