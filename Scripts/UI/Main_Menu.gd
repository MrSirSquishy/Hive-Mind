extends Control

@onready var best_wave_label: Label = $BestWaveLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	best_wave_label.text = "Highest Wave: %d" % Global.highest_wave


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().paused = false
	Global.reset_run()
	# turns the tutorial off
	Tutorial.stop()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Start Pressed") #checks if button pressed



func _on_tutorial_button_pressed() -> void:
	get_tree().paused = false
	Global.reset_run()
	Tutorial.start()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")


func _on_load_hive_button_pressed() -> void:
	if not Global.load_game():
		var button: Button = get_node_or_null("HBoxContainer/VBoxContainer/LoadHiveButton") as Button
		if button != null:
			button.text = "No Save"
		return
	get_tree().paused = false
	# turns the tutorial off
	Tutorial.stop()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")


func _on_settings_button_pressed() -> void:
	Global.open_settings()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed") #checks if button pressed
