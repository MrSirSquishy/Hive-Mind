extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_to_hive_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Return to Hive Pressed") #checks if button pressed


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/main_menu.tscn")
	print("Exit to Main Menu Pressed") #checks if button pressed


func _on_hat_button_pressed() -> void:
	print("Give the Bee a Hat") #checks if button pressed


func _on_equipment_button_1_pressed() -> void:
	print("Give the Bee an Equipment1") #checks if button pressed


func _on_equipment_button_2_pressed() -> void:
	print("Give the Bee an Equipment2") #checks if button pressed


func _on_face_button_pressed() -> void:
	print("Give the Bee a Face item") #checks if button pressed


func _on_shoes_button_pressed() -> void:
	print("Give the Bee a pair of Shoes") #checks if button pressed


func _on_tutorial_button_pressed() -> void:
	print("Point to Tutorial") #checks if button pressed
