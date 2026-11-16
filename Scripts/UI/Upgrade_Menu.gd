extends Control

const HEALTH_UPGRADE_COST: int = 5

var selected_bee: Entity = null

@onready var health_label: Label = $VBoxContainer/HealthInfoContainer/HealthLabel
@onready var health_button: Button = $VBoxContainer/HealthInfoContainer/HealthUpgradeButton

func _init() -> void:
	Signal_Bus.open_upgrade_menu.connect(open_for_bee)
	Signal_Bus.close_upgrade_menu.connect(close_menu)

func open_for_bee(bee: Entity) -> void:
	selected_bee = bee
	health_label.text = "%s / %s" % [bee.health, bee.max_health]
	# Update the UI with this bee's current stats
	#$Title.text = "Upgrading Bee"
	#$DefenseLabel.text = "Defense: %s" % bee.defense
	#$AttackLabel.text = "Attack: %s" % bee.attack
	show()


func _on_back_button_pressed() -> void:
	close_menu()

func close_menu() -> void:
	hide()

func _ready() -> void:
	health_button.text = str(HEALTH_UPGRADE_COST)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass

##need to fix all of this mess
func _on_bee_health_button_pressed() -> void:
	if not is_instance_valid(selected_bee) or not (selected_bee is Bee) or selected_bee.is_queued_for_deletion():
		return
	if Honey_Manager.spend_honey(HEALTH_UPGRADE_COST):
		selected_bee.upgrade_health(1.0)
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
