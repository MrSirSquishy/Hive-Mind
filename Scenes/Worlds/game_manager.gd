extends Node

const BEE = preload("res://Scenes/Bees/bee.tscn")
const ENEMY = preload("res://Scenes/Enemies/Stag_Beetle.tscn")

const BEE_MIDDLE = Vector2(0, 0)

#Time(in seconds) between each wave
@export var delay_between_waves : float = 3.0
#The minimum radius that enemies will spawn from the center
@export var wave_radius_min : float = 3000
#The maximum radius that enemies will spawn from teh enter
@export var wave_radius_max : float = 10000

@export var bee_respawn_waves = 3
@export var max_bees = 4
var alive = 0
var wave_count = 0
var enemy_count = 2
var bee_count = 0

func _ready():
	await get_tree().process_frame # wait for World to finish loading
	spawn_bees(max_bees)
	spawn_wave()

func spawn_bees(amount):
	for i in amount:

		var b = BEE.instantiate()
		b.position = BEE_MIDDLE + Vector2(
		randf_range(-100, 100), 
		randf_range(-100, 100)
		)
		b.died.connect(on_bee_died)
		get_tree().current_scene.add_child(b)
		bee_count += 1
		# put enemies in the corner

func spawn_wave():
	wave_count += 1
	enemy_count += 1
	alive = enemy_count
	for i in enemy_count:
		var enemy = ENEMY.instantiate()
		enemy.target_position = BEE_MIDDLE # tell enemy where to go
		enemy.position = Vector2.from_angle(randf_range(0, TAU)) * randf_range(wave_radius_min, wave_radius_max)
		enemy.died.connect(on_died)
		get_tree().current_scene.add_child(enemy)

func on_died():
	alive -= 1
	if alive > 0:
		return
		await get_tree().create_timer(5.0).timeout
		
	if wave_count % bee_respawn_waves == 0:
		var missing_bees = max_bees - bee_count
		
		if missing_bees > 0:
			spawn_bees(missing_bees)
	
	await get_tree().create_timer(delay_between_waves).timeout
	spawn_wave()
		
func on_bee_died():
	bee_count -= 1
