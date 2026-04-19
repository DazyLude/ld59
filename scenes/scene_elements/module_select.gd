extends Button
class_name ModuleButton

#
#signal picked;
#signal released;

#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var mbevent = event as InputEventMouseButton;
		#if mbevent.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#picked.emit();
		#if mbevent.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#released.emit();
