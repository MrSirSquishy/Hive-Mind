extends Control

@onready var honey_label: Label = $HoneyLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	_on_honey_changed(Honey_Manager.honey)
	

func _on_honey_changed(new_amount: int) -> void:
	honey_label.text = "Honey: %d" % new_amount


func _on_tutorial_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Tutorial Button Pressed") #checks if button pressed


func _on_return_to_hive_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Return to Hive Pressed") #checks if button pressed


func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Shop Menu/shop_menu.tscn")
	print("Shop Button Pressed") #checks if button pressed


func _on_settings_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Point to Settings") #checks if button pressed


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	print("Exit to Main Menu Pressed") #checks if button pressed
