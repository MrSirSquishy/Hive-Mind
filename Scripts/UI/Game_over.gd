extends Control #ui layer

func _ready() -> void:
	Signal_Bus.game_over.connect(_on_game_over)

func _on_game_over() -> void: #unhides menu and shows mouse
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Global.reset_run()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")

func _on_exit_to_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_settings_button_pressed() -> void:
	Global.open_settings()
