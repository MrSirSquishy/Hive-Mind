extends Control

signal upgrade_requested(bee: Node)
signal closed

var selected_bee: Node = null

#opens the submenu for the bee
func open_for(bee: Node) -> void:
	selected_bee = bee
	global_position = get_global_mouse_position() + Vector2(5, 5)  # appears near mouse
	show()

#opens upgrade menu for selected bee
func _on_upgrade_button_pressed() -> void:
	upgrade_requested.emit(selected_bee)
	hide()

#closes the submenu
func _on_close_button_pressed() -> void:
	closed.emit()
	hide()


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
