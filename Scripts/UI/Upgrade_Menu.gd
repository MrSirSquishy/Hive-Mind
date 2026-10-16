extends Control

@onready var honey_label: Label = $HoneyLabel

var selected_bee: Node = null

func open_for_bee(bee: Node) -> void:
	selected_bee = bee
	# Update the UI with this bee's current stats
	$Title.text = "Upgrading Bee"
	$DamageLabel.text = "Damage: %s" % bee.damage
	$SpeedLabel.text = "Speed: %s" % bee.attack_speed
	# etc.
	show()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(50):          # your cost
		selected_bee.upgrade_damage(5)         # only this bee
		open_for_bee(selected_bee)             # refresh the numbers

func _on_bee_defense_button_pressed() -> void:
	print("Increase Bee Defense") #checks if button pressed
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(50):
		selected_bee.upgrade_defense(0.1)
		open_for_bee(selected_bee)

func _on_bee_speed_button_pressed() -> void:
	print("Increase Bee Speed") #checks if button pressed
func _on_speed_upgrade_pressed() -> void:
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(30):
		selected_bee.upgrade_attack_speed(0.1)
		open_for_bee(selected_bee)

func _on_bee_health_button_pressed() -> void:
	print("Increase Bee Health") #checks if button pressed
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(50):
		selected_bee.upgrade_health(0.1)
		open_for_bee(selected_bee)
