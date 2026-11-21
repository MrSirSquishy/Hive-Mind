extends Node

const BEE : PackedScene = preload("res://Scenes/Bees/bee.tscn")
const ENEMY : PackedScene = preload("res://Scenes/Enemies/Stag_Beetle.tscn")

#The center position of the hive
@export var bee_middle : Vector2 = Vector2(0, 0)
#Time(in seconds) between each wave
@export var delay_between_waves : float = 3.0
#The minimum radius that enemies will spawn from the center
@export var wave_radius_min : float = 3000
#The maximum radius that enemies will spawn from the center
@export var wave_radius_max : float = 10000

#The approximate radius that bees will spawn from the hive
@export var bee_spawn_radius : float = 500

@export var waves_between_shops : int = 3
@export var max_bees : int = 6

@onready var alive : int = 0
@onready var wave_count : int = 0
@onready var wave_difficulty : float = 1
@onready var wave_difficulty_add_value : float = 0.5
@onready var bee_count : int = 0
@onready var is_wave_waiting : bool = false


var game_over: bool = false

##bee submenu variables
var bee_sub_menu: Control
var upgrade_menu: Control

func _ready() -> void:
	await get_tree().process_frame # wait for World to finish loading
	var hives : Array[Node] = get_tree().get_nodes_in_group("hive")
	if not hives.is_empty():
		var hive: Hive = hives[0] as Hive
		hive.died.connect(on_hive_destroyed)
	if not Global.loaded_run.is_empty():
		wave_count = int(Global.loaded_run["completed_wave"])
		wave_difficulty += wave_count
		spawn_bees(int(Global.loaded_run["bee_count"]))
		Global.loaded_run.clear()
	else:
		spawn_bees(max_bees)
	if Tutorial.active:
		Tutorial.finished.connect(spawn_wave, CONNECT_ONE_SHOT)
		Tutorial.show_current()
	else:
		spawn_wave()


func on_hive_destroyed() -> void:
	if game_over:
		return

	game_over = true
	is_wave_waiting = false
	Signal_Bus.game_over.emit()
	get_tree().paused = true

func spawn_bees(amount : int) -> void:
	if game_over:
		return
	for i : int in amount:

		var bee : Bee = BEE.instantiate()
		#Random spawn pos from center
		bee.position = bee_middle + Vector2.from_angle(randf_range(0, TAU)) * randf_range(0, bee_spawn_radius)
		bee.died.connect(on_bee_died)
		get_tree().current_scene.add_child(bee)
		bee_count += 1

func spawn_wave() -> void:
	Engine.time_scale = 1 # makes sure the time scale is correct
	if game_over:
		return
	is_wave_waiting = false
	Signal_Bus.hide_skip_wave_button.emit()
	
	wave_count += 1
	Global.register_wave_reached(wave_count)
	Signal_Bus.wave_changed.emit(wave_count)
	wave_difficulty += wave_difficulty_add_value
	alive = floor(wave_difficulty)
	for i : int in alive:
		var enemy : Enemy = ENEMY.instantiate()
		enemy.target_positions = [bee_middle] # tell enemy where to go
		#Random starting position
		enemy.position = Vector2.from_angle(randf_range(0, TAU)) * randf_range(wave_radius_min, wave_radius_max)
		enemy.died.connect(on_enemy_died)
		get_tree().current_scene.add_child(enemy)
	Signal_Bus.toast_requested.emit("Wave %d begins!" % wave_count, false)

func on_enemy_died() -> void:
	alive -= 1
	if alive > 0:
		return
		
	if wave_count % waves_between_shops == 0:
		# respawns bees
		var missing_bees : int = max_bees - bee_count
		if missing_bees > 0:
			spawn_bees(missing_bees)
			
		# opens shop
		Signal_Bus.show_shop_button.emit()
		#Global.open_overlay("res://Scenes/UI/shop_menu.tscn")
		#Signal_Bus.toast_requested.emit("Spend your honey in the shop!", false)
		#wait's for shop to close before going to next wave
		await Signal_Bus.close_shop

		Signal_Bus.toast_requested.emit("Wave %d cleared! The shop is available." % wave_count, false)
	
	var hives: Array[Node] = get_tree().get_nodes_in_group("hive")
	if not hives.is_empty():
		Global.save_run(wave_count, bee_count, (hives[0] as Hive).health)
	
	is_wave_waiting = true
	Signal_Bus.show_skip_wave_button.emit()
	var completed_wave: int = wave_count
	await get_tree().create_timer(delay_between_waves, false).timeout
	if is_wave_waiting and not game_over and wave_count == completed_wave:
		spawn_wave()
		
func on_bee_died() -> void:
	bee_count -= 1


##Bee Upgrades???
func upgrade_health() -> void:
	pass

func upgrade_defense() -> void:
	pass

func upgrade_attack() -> void:
	pass


## Signals
func _init() -> void:
	Signal_Bus.skip_wave.connect(_skip_wave)

func _skip_wave() -> void:
	if game_over:
		return

	if is_wave_waiting:
		spawn_wave()
