extends Control

const UpgradeOptionRow = preload("res://Scripts/UI/Upgrade_Option_Row.gd")
const SidebarDismissButton = preload("res://Scripts/UI/Sidebar_Dismiss_Button.gd")

const HEALTH_UPGRADE_COST: int = 5
const DEFENSE_UPGRADE_COST: int = 10
const ATTACK_UPGRADE_COST: int = 10

var selected_target: Body = null
var _last_defense: float = -1.0
var _last_attack: float = -1.0

@onready var dismiss_button: SidebarDismissButton = $Panel/DismissButton
@onready var name_label: Label = $Panel/Content/Column/Header/EntityName
@onready var honey_label: Label = $Panel/Content/Column/Header/HoneyLabel
@onready var summary_label: Label = $Panel/Content/Column/Summary
@onready var health_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/HealthRow
@onready var defense_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/DefenseRow
@onready var attack_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/AttackRow
@onready var equipment_label: Label = $Panel/Content/Column/EquipmentSummary
@onready var feedback_label: Label = $Panel/Content/Column/Feedback

@onready var health_button: Button = health_row.purchase_button
@onready var defense_button: Button = defense_row.purchase_button
@onready var attack_button: Button = attack_row.purchase_button

func _init() -> void:
	Signal_Bus.open_upgrade_menu.connect(open_for_body)
	Signal_Bus.close_upgrade_menu.connect(close_menu)

func _ready() -> void:
	dismiss_button.dismissed.connect(close_menu)
	health_button.pressed.connect(_on_bee_health_button_pressed)
	defense_button.pressed.connect(_on_defense_upgrade_button_pressed)
	attack_button.pressed.connect(_on_attack_upgrade_button_pressed)
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	hide()

func open_for_body(target: Body) -> void:
	if not (target is Bee) or not is_instance_valid(target) or target.is_queued_for_deletion():
		close_menu()
		return
	if dismiss_button.is_sliding():
		close_menu()
	if selected_target != target:
		_disconnect_bee()
		feedback_label.hide()
	selected_target = target
	var bee: Bee = target as Bee
	if not bee.health_changed.is_connected(_on_bee_health_changed):
		bee.health_changed.connect(_on_bee_health_changed)
	refresh()
	show()
	Global.call_deferred("update_world_cursor")

func refresh() -> void:
	if not is_instance_valid(selected_target) or selected_target.is_queued_for_deletion() or not (selected_target is Bee):
		close_menu()
		return

	var bee: Bee = selected_target as Bee
	name_label.text = bee.bee_name
	honey_label.text = "%d honey" % Honey_Manager.honey
	summary_label.text = "HP %.0f / %.0f    Defense %.0f%%    Attack %.1f" % [bee.health, bee.max_health, bee.damage_reduction * 100.0, bee.attack_damage]

	health_row.configure(
		"Health", "Increase maximum and current HP by 1.",
		"Max HP  %.0f  →  %.0f" % [bee.max_health, bee.max_health + 1.0],
		HEALTH_UPGRADE_COST, _reason(HEALTH_UPGRADE_COST), preload("res://Assets/UI/Heart.svg")
	)
	defense_row.configure(
		"Defense", "Block 10% more incoming damage (up to 80%).",
		"Damage blocked  %.0f%%  →  %.0f%%" % [bee.damage_reduction * 100.0, minf(0.8, bee.damage_reduction + 0.1) * 100.0],
		DEFENSE_UPGRADE_COST,
		_reason(DEFENSE_UPGRADE_COST, bee.damage_reduction >= 0.8 - 0.0001),
		preload("res://Assets/UI/Shield.svg")
	)
	attack_row.configure(
		"Attack", "Increase current attack damage by 0.1.",
		"Damage  %.1f  →  %.1f" % [bee.attack_damage, bee.attack_damage + 0.1],
		ATTACK_UPGRADE_COST, _reason(ATTACK_UPGRADE_COST), preload("res://Assets/UI/Sword.svg")
	)

	var equipment: PackedStringArray = []
	for pair: Array in [["HEAD", "Head"], ["BODY", "Body"], ["EQUIPMENT", "Gear"]]:
		var equipped: Upgrade = bee.upgrades[pair[0]] as Upgrade
		var equipped_name: String = "None"
		if is_instance_valid(equipped):
			equipped_name = equipped.display_name if not equipped.display_name.is_empty() else equipped.name
		equipment.append("%s: %s" % [pair[1], equipped_name])
	equipment_label.text = "Equipped  •  " + "   |   ".join(equipment)
	_last_defense = bee.damage_reduction
	_last_attack = bee.attack_damage

func _process(_delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(selected_target) or selected_target.is_queued_for_deletion():
		close_menu()
		return
	if selected_target is Bee:
		var bee: Bee = selected_target as Bee
		if not is_equal_approx(bee.damage_reduction, _last_defense) or not is_equal_approx(bee.attack_damage, _last_attack):
			refresh()

func _reason(cost: int, at_cap: bool = false) -> String:
	if at_cap:
		return "Already at maximum"
	if not Honey_Manager.can_afford(cost):
		return "Not enough honey"
	return ""

func _can_purchase(cost: int) -> bool:
	return selected_target is Bee and is_instance_valid(selected_target) and not selected_target.is_queued_for_deletion() and Honey_Manager.can_afford(cost)

func _disconnect_bee() -> void:
	if is_instance_valid(selected_target) and selected_target is Bee:
		var bee: Bee = selected_target as Bee
		if bee.health_changed.is_connected(_on_bee_health_changed):
			bee.health_changed.disconnect(_on_bee_health_changed)

func close_menu() -> void:
	_disconnect_bee()
	selected_target = null
	feedback_label.hide()
	hide()
	dismiss_button.reset_slide()
	Global.call_deferred("update_world_cursor")

func _on_bee_health_changed(_current: float, _maximum: float) -> void:
	if visible:
		refresh()

func _on_honey_changed(_honey: int) -> void:
	if visible:
		refresh()

func _show_feedback(message: String) -> void:
	feedback_label.text = message
	feedback_label.show()

func _on_bee_health_button_pressed() -> void:
	if not _can_purchase(HEALTH_UPGRADE_COST):
		return
	(selected_target as Bee).upgrade_health(1.0)
	Honey_Manager.spend_honey(HEALTH_UPGRADE_COST)
	refresh()
	_show_feedback("Health upgraded: +1 max HP")

func _on_defense_upgrade_button_pressed() -> void:
	if not _can_purchase(DEFENSE_UPGRADE_COST):
		return
	var bee: Bee = selected_target as Bee
	if bee.damage_reduction >= 0.8 - 0.0001:
		return
	bee.upgrade_defense(0.1)
	Honey_Manager.spend_honey(DEFENSE_UPGRADE_COST)
	refresh()
	_show_feedback("Defense upgraded: +10% damage reduction")

func _on_attack_upgrade_button_pressed() -> void:
	if not _can_purchase(ATTACK_UPGRADE_COST):
		return
	(selected_target as Bee).upgrade_attack(0.1)
	Honey_Manager.spend_honey(ATTACK_UPGRADE_COST)
	refresh()
	_show_feedback("Attack upgraded: +0.1 damage")
