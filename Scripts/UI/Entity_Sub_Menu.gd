extends Control

@onready var entity_name : Label = $VBoxContainer/EntityName

@onready var entity_info : Dictionary = {
	"HEALTH" = $VBoxContainer/HealthInfoContainer,
	"ATTACK" = $VBoxContainer/AttackInfoContainer
}
@onready var action_buttons : Dictionary = {
	"ATTACK" = $VBoxContainer/VBoxContainer/AttackButton,
	"DEFEND AREA" = $VBoxContainer/VBoxContainer/DefendAreaButton,
	"DEFEND HIVE" = $VBoxContainer/VBoxContainer/DefendHiveButton,
	"SELECTION" = $VBoxContainer/VBoxContainer/SelectionButton
}
@onready var upgrade_button: Button = $VBoxContainer/VBoxContainer/UpgradeButton
@onready var cancel_button: Button = $VBoxContainer/VBoxContainer/CancelButton

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

func _ready() -> void:
	Signal_Bus.open_sub_menu.connect(open_menu)
	Signal_Bus.close_sub_menu.connect(close_menu)
	#Connects button signals to Signal Bus
	action_buttons["ATTACK"].connect("pressed", func() -> void: Signal_Bus.attack_signal.emit())
	action_buttons["DEFEND AREA"].connect("pressed", func() -> void: Signal_Bus.defend_area_signal.emit())
	action_buttons["DEFEND HIVE"].connect("pressed", func() -> void: Signal_Bus.defend_hive_signal.emit())
	action_buttons["SELECTION"].connect("pressed", func() -> void: Signal_Bus.selection_signal.emit())
	

#opens the submenu for the bee
func open_menu(entities : Array[Entity], upgrade : Upgrade) -> void:
	entity_name.hide()
	if entities.size() == 0:
		return
	elif entities.size() == 1:
		selected_entity = entities[0]
		if selected_entity is Bee: #Updates the entity name text
			entity_name.text = selected_entity.bee_name
		else:
			entity_name.text = "Selection"
		
		if entity_name.text != "":
				entity_name.show()
		entity_info.HEALTH.show()
		entity_info.ATTACK.show()
		entity_info.HEALTH.find_children("", "Label")[0].text = str(selected_entity.health)
		entity_info.ATTACK.find_children("", "Label")[0].text = str(selected_entity.attack_damage)
	else:
		entity_info.HEALTH.hide()
		entity_info.ATTACK.hide()
		entity_name.text = "Selection"
		entity_name.show()
	
	
	if upgrade: #If upgrade is passed, then that means this should be an upgrade menu
		for button : String in action_buttons:
			action_buttons[button].visible = false
		upgrade_button.show()
		cancel_button.show()
		
		if selected_entity: #If the entity already has an upgrade of that type, it cannot be upgraded
			if selected_entity.upgrades[upgrade.upgrade_type] == null:
				upgrade_button.disabled = false
			else:
				upgrade_button.disabled = true
	
	else: #Shows or hides action buttons if the selection is bees or not
		var show_button : bool = entities[0] is Bee
		for button : String in action_buttons:
			action_buttons[button].visible = show_button
		upgrade_button.hide()
		cancel_button.hide()
		
	show()

func close_menu() -> void:
	Signal_Bus.selection_signal.emit()
	hide()
	

func _on_upgrade_button_pressed() -> void:
	close_menu()
	Signal_Bus.upgrade_finished_signal.emit(false)

func _on_cancel_button_pressed() -> void:
	close_menu()
	Signal_Bus.upgrade_finished_signal.emit(true)
