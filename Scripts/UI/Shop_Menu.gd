extends Control

class Upgrade_Button:
	var button : Button
	var label : Label
	
	func _init(_button : Button) -> void:
		button = _button
		label = button.get_node("Label")
		
	func randomize_upgrade() -> void:
		pass

@onready var shop_item_buttons : Array[Upgrade_Button] = [
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade1),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade2),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade3),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade4)
]


const UPGRADE_DIRECTORY := "res://Scenes/Upgrades/"
const rarity_weights : Array[int] = [
	60, #COMMON
	25, #UNCOMMON
	12, #RARE
	3   #LEGENDARY
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for upgrade_button : Upgrade_Button in shop_item_buttons:
		upgrade_button.randomize_upgrade()
	

func _on_return_to_hive_button_pressed() -> void:
	Signal_Bus.close_shop.emit()
	Global.close_overlay()
