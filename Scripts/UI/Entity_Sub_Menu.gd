extends Control


var selected_entity: Node = null

#opens upgrade menu for selected bee
func _on_entity_upgrade_button_pressed() -> void:
	if selected_entity == null:
		return
	
# Directly tell the upgrade menu to open for this bee
	Signal_Bus.open_upgrade_menu.emit(selected_entity)
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
	show()

func close_menu() -> void:
	hide()
	
