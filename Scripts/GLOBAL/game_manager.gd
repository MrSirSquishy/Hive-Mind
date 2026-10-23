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

@export var waves_between_shops : int = 5
@export var max_bees : int = 4

@onready var alive : int = 0
@onready var wave_count : int = 0
@onready var enemy_count : int = 2
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
	spawn_bees(max_bees)
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
	if game_over:
		return
	is_wave_waiting = false
	Signal_Bus.hide_skip_wave_button.emit()
	
	wave_count += 1
	enemy_count += 1
	alive = enemy_count
	for i : int in enemy_count:
		var enemy : Enemy = ENEMY.instantiate()
		enemy.target_positions = [bee_middle] # tell enemy where to go
		#Random starting position
		enemy.position = Vector2.from_angle(randf_range(0, TAU)) * randf_range(wave_radius_min, wave_radius_max)
		enemy.died.connect(on_enemy_died)
		get_tree().current_scene.add_child(enemy)

func on_enemy_died() -> void:
	alive -= 1
	if alive > 0:
		return
		
	if wave_count % waves_between_shops == 0:
		var missing_bees : int = max_bees - bee_count
		
		if missing_bees > 0:
			spawn_bees(missing_bees)
	
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
