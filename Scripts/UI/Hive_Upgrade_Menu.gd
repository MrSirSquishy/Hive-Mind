extends Control

const UpgradeOptionRow = preload("res://Scripts/UI/Upgrade_Option_Row.gd")
const SidebarDismissButton = preload("res://Scripts/UI/Sidebar_Dismiss_Button.gd")

const REINFORCE_COST: int = 25
const FORTIFY_COST: int = 35
const REPAIR_COST: int = 10
const REGEN_COST: int = 50

const REINFORCE_AMOUNT: float = 5.0
const FORTIFY_AMOUNT: float = 0.05
const REPAIR_AMOUNT: float = 10.0
const REGEN_AMOUNT: float = 0.25

var selected_hive: Hive = null
var _last_defense: float = -1.0
var _last_regen: float = -1.0

@onready var dismiss_button: SidebarDismissButton = $Panel/DismissButton
@onready var name_label: Label = $Panel/Content/Column/Header/EntityName
@onready var honey_label: Label = $Panel/Content/Column/Header/HoneyLabel
@onready var summary_label: Label = $Panel/Content/Column/Summary
@onready var reinforce_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/HealthRow
@onready var fortify_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/DefenseRow
@onready var repair_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/RepairRow
@onready var regen_row: UpgradeOptionRow = $Panel/Content/Column/Scroll/Rows/RegenRow
@onready var equipment_label: Label = $Panel/Content/Column/EquipmentSummary
@onready var feedback_label: Label = $Panel/Content/Column/Feedback

@onready var reinforce_button: Button = reinforce_row.purchase_button
@onready var fortify_button: Button = fortify_row.purchase_button
@onready var repair_button: Button = repair_row.purchase_button
@onready var regen_button: Button = regen_row.purchase_button

func _init() -> void:
	Signal_Bus.open_upgrade_menu.connect(open_for_body)
	Signal_Bus.close_upgrade_menu.connect(close_menu)

func _ready() -> void:
	dismiss_button.dismissed.connect(close_menu)
	reinforce_button.pressed.connect(_on_reinforce_pressed)
	fortify_button.pressed.connect(_on_fortify_pressed)
	repair_button.pressed.connect(_on_repair_pressed)
	regen_button.pressed.connect(_on_regen_pressed)
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	hide()

func open_for_body(target: Body) -> void:
	if not (target is Hive) or not is_instance_valid(target) or target.is_queued_for_deletion():
		close_menu()
		return
	if dismiss_button.is_sliding():
		close_menu()
	if selected_hive != target:
		_disconnect_hive()
		feedback_label.hide()
	selected_hive = target as Hive
	if not selected_hive.health_changed.is_connected(_on_hive_health_changed):
		selected_hive.health_changed.connect(_on_hive_health_changed)
	refresh()
	show()
	Global.call_deferred("update_world_cursor")

func refresh() -> void:
	if not is_instance_valid(selected_hive) or selected_hive.is_queued_for_deletion():
		close_menu()
		return
	var hive: Hive = selected_hive
	name_label.text = "Hive"
	honey_label.text = "%d honey" % Honey_Manager.honey
	summary_label.text = "HP %.0f / %.0f    Defense %.0f%%    Regen %.2f/s" % [hive.health, hive.max_health, hive.damage_reduction * 100.0, hive.regeneration_rate]

	reinforce_row.configure(
		"Reinforce", "Increase maximum HP and restore 5 HP.",
		"Max HP  %.0f  →  %.0f" % [hive.max_health, hive.max_health + REINFORCE_AMOUNT],
		REINFORCE_COST, _reason(REINFORCE_COST), preload("res://Assets/UI/Heart.svg")
	)
	fortify_row.configure(
		"Fortify", "Block 5% more incoming damage (up to 80%).",
		"Damage blocked  %.0f%%  →  %.0f%%" % [hive.damage_reduction * 100.0, minf(0.8, hive.damage_reduction + FORTIFY_AMOUNT) * 100.0],
		FORTIFY_COST, _reason(FORTIFY_COST, hive.damage_reduction >= 0.8 - 0.0001), preload("res://Assets/UI/Shield.svg")
	)
	repair_row.configure(
		"Repair", "Restore up to 10 missing HP, without raising the cap.",
		"HP  %.0f  →  %.0f" % [hive.health, minf(hive.max_health, hive.health + REPAIR_AMOUNT)],
		REPAIR_COST, _reason(REPAIR_COST, hive.health >= hive.max_health - 0.0001, "Hive is already at full HP"), preload("res://Assets/UI/Heart.svg")
	)
	regen_row.configure(
		"Regenerate", "Heal passively each second (up to 2 HP/s).",
		"HP/sec  %.2f  →  %.2f" % [hive.regeneration_rate, minf(Hive.MAX_REGEN_RATE, hive.regeneration_rate + REGEN_AMOUNT)],
		REGEN_COST, _reason(REGEN_COST, hive.regeneration_rate >= Hive.MAX_REGEN_RATE - 0.0001), preload("res://Assets/UI/Heart.svg")
	)
	equipment_label.text = "Upgrade effects apply immediately."
	_last_defense = hive.damage_reduction
	_last_regen = hive.regeneration_rate

func _process(_delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(selected_hive) or selected_hive.is_queued_for_deletion():
		close_menu()
		return
	if not is_equal_approx(selected_hive.damage_reduction, _last_defense) or not is_equal_approx(selected_hive.regeneration_rate, _last_regen):
		refresh()

func _reason(cost: int, at_cap: bool = false, cap_reason: String = "Already at maximum") -> String:
	if at_cap:
		return cap_reason
	if not Honey_Manager.can_afford(cost):
		return "Not enough honey"
	return ""

func _disconnect_hive() -> void:
	if is_instance_valid(selected_hive) and selected_hive.health_changed.is_connected(_on_hive_health_changed):
		selected_hive.health_changed.disconnect(_on_hive_health_changed)

func close_menu() -> void:
	_disconnect_hive()
	selected_hive = null
	feedback_label.hide()
	hide()
	dismiss_button.reset_slide()
	Global.call_deferred("update_world_cursor")

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel") or event.is_echo():
		return
	if Global.freeze_activity or get_tree().paused:
		return
	get_viewport().set_input_as_handled()
	close_menu()

func _on_hive_health_changed(_current: float, _maximum: float) -> void:
	if visible:
		refresh()

func _on_honey_changed(_honey: int) -> void:
	if visible:
		refresh()

func _can_purchase(cost: int) -> bool:
	return is_instance_valid(selected_hive) and not selected_hive.is_queued_for_deletion() and not selected_hive.is_destroyed and Honey_Manager.can_afford(cost)

func _show_feedback(message: String) -> void:
	feedback_label.text = message
	feedback_label.show()

func _on_reinforce_pressed() -> void:
	if not _can_purchase(REINFORCE_COST):
		return
	selected_hive.upgrade_max_health(REINFORCE_AMOUNT)
	Honey_Manager.spend_honey(REINFORCE_COST)
	refresh()
	_show_feedback("Hive reinforced: +5 maximum HP")

func _on_fortify_pressed() -> void:
	if not _can_purchase(FORTIFY_COST) or selected_hive.damage_reduction >= 0.8 - 0.0001:
		return
	selected_hive.upgrade_defense(FORTIFY_AMOUNT)
	Honey_Manager.spend_honey(FORTIFY_COST)
	refresh()
	_show_feedback("Hive fortified: +5% damage reduction")

func _on_repair_pressed() -> void:
	if not _can_purchase(REPAIR_COST) or selected_hive.health >= selected_hive.max_health - 0.0001:
		return
	selected_hive.heal(REPAIR_AMOUNT)
	Honey_Manager.spend_honey(REPAIR_COST)
	refresh()
	_show_feedback("Hive repaired: up to 10 HP restored")

func _on_regen_pressed() -> void:
	if not _can_purchase(REGEN_COST) or selected_hive.regeneration_rate >= Hive.MAX_REGEN_RATE - 0.0001:
		return
	selected_hive.upgrade_regeneration(REGEN_AMOUNT)
	Honey_Manager.spend_honey(REGEN_COST)
	refresh()
	_show_feedback("Hive regeneration increased: +0.25 HP/s")
