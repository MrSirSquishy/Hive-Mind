extends Control

@onready var honey_label: Label = $HoneyLabel


func _ready() -> void:
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	_on_honey_changed(Honey_Manager.honey)
	

func _on_honey_changed(new_amount: int) -> void:
	honey_label.text = "Honey: %d" % new_amount
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_return_to_hive_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn")
	print("Return to Hive Pressed") #checks if button pressed


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	print("Exit to Main Menu Pressed") #checks if button pressed


func _on_hive_defense_button_pressed() -> void:
	print("Increase Hive Defense") #checks if button pressed


func _on_hive_health_button_pressed() -> void:
	print("Increase Hive Health") #checks if button pressed



func _on_bee_damage_button_pressed() -> void:
	print("Increase Bee Damage") #checks if button pressed


func _on_bee_defense_button_pressed() -> void:
	print("Increase Bee Defense") #checks if button pressed


func _on_bee_speed_button_pressed() -> void:
	print("Increase Bee Speed") #checks if button pressed


func _on_bee_health_button_pressed() -> void:
	print("Increase Bee Health") #checks if button pressed
