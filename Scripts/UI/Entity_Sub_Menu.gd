extends Control

@onready var entity_name : Label = $VBoxContainer/EntityName

@onready var entity_info : Dictionary = {
	"HEALTH" = $VBoxContainer/HealthInfoContainer,
	"ATTACK" = $VBoxContainer/AttackInfoContainer
}

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
func open_menu(entities : Array[Entity]) -> void:
	entity_name.hide()
	if entities.size() == 0:
		return
	elif entities.size() == 1:
		selected_entity = entities[0]
		if selected_entity is Bee: #Updates the entity name text
			entity_name.text = selected_entity.bee_name
			if entity_name.text != "":
				entity_name.show()
		
		entity_info.HEALTH.show()
		entity_info.ATTACK.show()
		entity_info.HEALTH.find_children("", "Label")[0].text = str(selected_entity.health)
		entity_info.ATTACK.find_children("", "Label")[0].text = str(selected_entity.attack_damage)
	else:
		entity_info.HEALTH.hide()
		entity_info.ATTACK.hide()
		
	show()

func close_menu() -> void:
	hide()
	
