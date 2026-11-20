extends Control

@onready var best_wave_label: Label = $BestWaveLabel
@onready var load_hive_button: Button = $HBoxContainer/VBoxContainer/LoadHiveButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Tutorial.stop()
	
	best_wave_label.text = "Highest Wave: %d" % Global.highest_wave
	load_hive_button.disabled = not Global.has_saved_run()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().paused = false
	Global.reset_run()
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Start Pressed") #checks if button pressed



func _on_tutorial_button_pressed() -> void:
	var guide: AcceptDialog = AcceptDialog.new()
	guide.title = "How to Play"
	guide.dialog_text = "Protect your hive from each wave of bugs.\n\nSelect a bee with the left mouse button. Right-click and drag to move the camera; use WASD or the arrow keys to pan and the mouse wheel to zoom.\n\nPress G, then click or drag to choose a guard area. Press R to return selected bees to the hive, and H to center the camera.\n\nDefeat every enemy to begin the next wave. The hive is saved after each cleared wave; Load Hive resumes from that checkpoint."
	guide.confirmed.connect(guide.queue_free)
	guide.canceled.connect(guide.queue_free)
	add_child(guide)
	guide.popup_centered(Vector2i(900, 520))


func _on_load_hive_button_pressed() -> void:
	if Global.load_run():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	else:
		load_hive_button.disabled = true


func _on_settings_button_pressed() -> void:
	Global.open_settings()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed") #checks if button pressed
