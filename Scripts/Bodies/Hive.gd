class_name Hive extends Body

signal damaged(amount: float)

## percent of damage blocked, can be used for future upgrades 
@export_range(0.0, 0.8, 0.1) var damage_reduction: float = 0.0
const MAX_REGEN_RATE: float = 2.0
var regeneration_rate: float = 0.0
var is_destroyed: bool = false

@onready var upgrades : Array[Hive_Upgrade] = []
@onready var detection_area : Detection_Area = get_node("Detection_Area")

func _ready() -> void:
	#lets ui find the hive
	add_to_group("hive")
	#applies upgrades
	max_health += Global.hive_max_health_bonus
	damage_reduction = clampf(damage_reduction + Global.hive_defense_bonus, 0.0, 0.8)
	health = max_health
	health_changed.emit(health, max_health)
	#Signals
	Signal_Bus.attach_default_detection_area.connect(_attach_hive_detection_area)
	
	#init upgrades
	var child_upgrades : Array[Node] = find_children("", "Hive_Upgrade")
	for upgrade : Hive_Upgrade in child_upgrades:
		upgrades.append(upgrade)
		upgrade.init(self)
	if not Global.loaded_run.is_empty():
		health = clampf(float(Global.loaded_run["hive_health"]), 1.0, max_health)
		health_changed.emit(health, max_health)
	
#Entities can request the hives detection area, this executes that
func _attach_hive_detection_area(entity : Entity) -> void:
	entity.set_detection_area(detection_area)	

func _physics_process(dt: float) -> void:
	update_i_frames(dt)
	if not Global.freeze_activity and not is_destroyed and regeneration_rate > 0.0 and health < max_health:
		heal(regeneration_rate * dt)


func damage(damage_amount: float, source_identifier: String = "", i_frames: float = 0.0) -> bool:
	#hive ignores damage when destroyed
	#negative damage heals hive
	if is_destroyed:
		return false
	if damage_amount == 0.0:
		return false
	if damage_amount < 0.0:
		heal(-damage_amount)
		return false
	if i_frame_dictionary.has(source_identifier):
		return false
	if i_frames > 0.0:
		i_frame_dictionary[source_identifier] = i_frames

	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 3, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	var actual_damage : float =  damage_amount * (1.0 - damage_reduction)
	health = max(health - actual_damage, 0.0)
	##for ui
	damaged.emit(actual_damage)
	health_changed.emit(health, max_health)
	##kill hive
	if health <= 0.0:
		kill()
	
	return true

func heal(amount: float) -> void:
	if is_destroyed:
		return
	if amount <= 0.0:
		return
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
	
func kill() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	died.emit()


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

func upgrade_regeneration(amount: float) -> void:
	if amount > 0.0:
		regeneration_rate = clampf(regeneration_rate + amount, 0.0, MAX_REGEN_RATE)
