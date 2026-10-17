extends Control

signal upgrade_requested(bee: Node)
signal closed

var selected_entity: Node = null

#opens upgrade menu for selected bee
func _on_entity_upgrade_button_pressed() -> void:
	upgrade_requested.emit(selected_entity)
	hide()

#closes the submenu
func _on_entity_bee_menu_button_pressed() -> void:
	close_menu()
	

## Signals

func _init() -> void:
	Signal_Bus.open_sub_menu.connect(open_menu)
	Signal_Bus.close_sub_menu.connect(close_menu)

#opens the submenu for the bee
func open_menu(entity: Entity) -> void:
	selected_entity = entity
	global_position = get_global_mouse_position() + Vector2(5, 5)  # appears near mouse
	show()

func close_menu() -> void:
	closed.emit()
	hide()
