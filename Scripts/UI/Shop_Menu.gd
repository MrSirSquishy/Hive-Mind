extends Control

@onready var honey_label: Label = $HoneyLabel
@export var cost_hat: int = 7
@export var cost_equip1: int = 4
@export var cost_equip2: int = 5
@export var cost_face: int = 2
@export var cost_shoes: int = 5



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	_on_honey_changed(Honey_Manager.honey)
	

func _on_honey_changed(new_amount: int) -> void:
	honey_label.text = "Honey: %d" % new_amount
	

func _on_return_to_hive_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Return to Hive Pressed") #checks if button pressed


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	print("Exit to Main Menu Pressed") #checks if button pressed


func _on_hat_button_pressed() -> void:
	if Honey_Manager.spend_honey(cost_hat):
		print("Purchased, give the bee a hat")
	else:
		print("Not enough honey, sorry!")
	
	
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
