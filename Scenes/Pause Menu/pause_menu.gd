extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tutorial_button_pressed() -> void:
	print("Tutorial Button Pressed") #checks if button pressed


func _on_return_to_hive_button_pressed() -> void:
	print("Return to Hive Pressed") #checks if button pressed


func _on_shop_button_pressed() -> void:
	print("Shop Button Pressed") #checks if button pressed


func _on_settings_button_pressed() -> void:
	print("Settings Button Pressed") #checks if button pressed


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/main_menu.tscn")
	print("Exit to Main Menu Pressed") #checks if button pressed
