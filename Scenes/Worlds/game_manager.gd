extends Node

const BEE = preload("res://Scenes/Bees/bee.tscn")
const ENEMY = preload("res://Scenes/Enemies/Stag_Beetle.tscn")

const BEE_MIDDLE = Vector2(0, 0)
const ENEMY_CORNER = Vector2(-4500, -3000) # corner of the starting view

var alive = 0

func _ready():
	await get_tree().process_frame # wait for World to finish loading
	spawn_bees()
	spawn_wave()

func spawn_bees():
	for i in 4:
		var b = BEE.instantiate()
		b.position = BEE_MIDDLE + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		get_tree().current_scene.add_child(b)

# Spawn 3 enemies in the corner
func spawn_wave():
	alive = 3
	for i in 3:
		var e = ENEMY.instantiate()
		e.position = ENEMY_CORNER + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		e.died.connect(on_died)
		get_tree().current_scene.add_child(e)

func on_died():
	alive -= 1
	if alive == 0:
		await get_tree().create_timer(5.0).timeout
		spawn_wave()
