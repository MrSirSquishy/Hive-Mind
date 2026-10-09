class_name Hive
extends StaticBody2D

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal destroyed

@export_group("Health")
@export var max_health: float = 120.0
@export var radius: float = 150.0
## percent of damage blocked, can be used for future upgrades 
@export_range(0.0, 0.8, 0.1)
var damage_reduction: float = 0.0
@export var team: String = "BEES"

var health: float
var is_destroyed: bool = false

func _ready() -> void:
	#lets ui find the hive
	add_to_group("hive")
	health = max_health
	health_changed.emit(health, max_health)
	
func damage(amount: float) -> void:
	#hive ignores damage when destroyed
	#negative damage heals hive
	if is_destroyed:
		return
	if amount == 0.0:
		return
	if amount < 0.0:
		heal(-amount)
		return

	var actual_damage : float =  amount * (1.0 - damage_reduction)
	health = max(health - actual_damage, 0.0)
	##for ui
	damaged.emit(actual_damage)
	health_changed.emit(health, max_health)
	##destroy hive
	if health <= 0.0:
		destroy()

func heal(amount: float) -> void:
	if is_destroyed:
		return
	if amount <= 0.0:
		return
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
	
func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	destroyed.emit()
##upgrades
func upgrade_max_health(amount: float) -> void:
	max_health += amount
	health += amount
	health_changed.emit(health, max_health)
func upgrade_defense(amount: float) -> void:
	damage_reduction = clamp(
		damage_reduction + amount,
		0.0,
		0.8
	)
