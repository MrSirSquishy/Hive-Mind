extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_tutorial_button_pressed() -> void:
	#get_tree().change_scene_to_file("")
	print("Tutorial Button Pressed") #checks if button pressed


func _on_return_to_hive_button_pressed() -> void:
	Global.close_overlay()


func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Shop Menu/shop_menu.tscn")
	print("Shop Button Pressed") #checks if button pressed


func _on_settings_button_pressed() -> void:
	Global.open_settings()


func _on_exit_to_menu_button_pressed() -> void:
	Global.close_overlay()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
