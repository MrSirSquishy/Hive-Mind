extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Start Pressed") #checks if button pressed


func _on_settings_pressed() -> void:
	print("Settings Pressed") #checks if button pressed


func _on_exit_pressed() -> void:
	get_tree().quit()
	print("Exit Pressed") #checks if button pressed
