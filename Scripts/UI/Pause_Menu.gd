extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Panel/VBoxContainer/HBoxContainer/VBoxContainer/TutorialButton.visible = Tutorial.active

func _on_restart_tutorial_button_pressed() -> void:
	Global.close_overlay()
	Tutorial.start()


func _on_return_to_hive_button_pressed() -> void:
	Global.close_overlay()


func _on_settings_button_pressed() -> void:
	Global.open_settings()


func _on_exit_to_menu_button_pressed() -> void:
	Global.close_overlay()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
