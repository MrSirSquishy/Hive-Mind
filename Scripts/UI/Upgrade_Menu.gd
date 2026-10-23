extends Control


var selected_bee: Node = null

func _init() -> void:
	Signal_Bus.open_upgrade_menu.connect(open_for_bee)
	Signal_Bus.close_upgrade_menu.connect(close_menu)

func open_for_bee(bee: Node) -> void:
	selected_bee = bee
	# Update the UI with this bee's current stats
	#$Title.text = "Upgrading Bee"
	#$HealthLabel.text = "Health: %s" % bee.health
	#$DefenseLabel.text = "Defense: %s" % bee.defense
	#$AttackLabel.text = "Attack: %s" % bee.attack
	show()


func _on_back_button_pressed() -> void:
	close_menu()

func close_menu() -> void:
	hide()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass

##need to fix all of this mess
func _on_bee_health_button_pressed() -> void:
	print("pressed")
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(5):
		print("Health+")
		selected_bee.upgrade_health(0.1)
		open_for_bee(selected_bee)


func _on_defense_upgrade_button_pressed() -> void:
	print("pressed")
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(10):
		print("Defense+")
		selected_bee.upgrade_defense(0.1)
		open_for_bee(selected_bee)


func _on_attack_upgrade_button_pressed() -> void:
	print("pressed")
	if selected_bee == null:
		return
	if Honey_Manager.spend_honey(10):
		print("Attack+")
		selected_bee.upgrade_attack(0.1)
		open_for_bee(selected_bee)
