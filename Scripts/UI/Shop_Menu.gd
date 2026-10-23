extends Control

@export var cost_hat: int = 7
@export var cost_equip1: int = 4
@export var cost_equip2: int = 5
@export var cost_face: int = 2
@export var cost_shoes: int = 5



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_return_to_hive_button_pressed() -> void:
	Global.close_overlay()


func _on_exit_to_menu_button_pressed() -> void:
	Global.close_overlay()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_hat_button_pressed() -> void:
	print("Hat is not implemented yet")


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
