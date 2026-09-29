extends Node
#wave scheduler, lives in world.tscn so the world tears it down for us

#emitted when the last enemy of the wave dies
signal wave_empty

#the waves in order, drag the .tres files in here
@export var waves: Array[WaveData] = []

#seconds of quiet before wave 1
@export var first_wave_delay: float = 5.0
#seconds of quiet between waves
@export var time_between_waves: float = 30.0
#how far off screen enemies appear, too small and they pop in on your bees
@export var spawn_margin: float = 90.0

#enemies of this wave still standing
var enemies_alive: int = 0


#connect once, then fire and forget the loop
func _ready() -> void:
	Signal_Bus.entity_died.connect(_on_entity_died)
	_run_waves()


#runs the whole run as one coroutine
func _run_waves() -> void:
	if Game_Manager.run_failed:
		return

	#already beat every wave
	if Game_Manager.wave_index >= waves.size():
		return

	#first wave waits first_wave_delay, later waves wait time_between_waves.
	#restart after leaving world skips the wait and drops straight back in
	if not Game_Manager.wave_in_progress:
		var delay := first_wave_delay \
			if Game_Manager.wave_index == 0 \
			else time_between_waves

		await get_tree().create_timer(delay).timeout

		if Game_Manager.run_failed:
			return

	while Game_Manager.wave_index < waves.size():
		var wave := waves[Game_Manager.wave_index]

		#no enemy scene means this wave could never finish, so stop
		if wave == null or wave.enemy_scene == null:
			push_error(
				"[Waves] Wave %d has no enemy scene"
				% [Game_Manager.wave_index + 1]
			)
			return

		Game_Manager.wave_in_progress = true

		Signal_Bus.wave_started.emit(Game_Manager.wave_index + 1)

		print(
			"[Waves] wave %d/%d started, %d enemies"
			% [
				Game_Manager.wave_index + 1,
				waves.size(),
				wave.count
			]
		)

		await _spawn_wave(wave)

		if Game_Manager.run_failed:
			return

		#some enemies may have died while we were still spawning
		if enemies_alive > 0:
			await wave_empty

		if Game_Manager.run_failed:
			return

		var cleared_wave := Game_Manager.wave_index + 1

		Game_Manager.wave_in_progress = false
		Game_Manager.wave_index += 1

		Signal_Bus.wave_cleared.emit(cleared_wave)

		print("[Waves] wave %d cleared" % cleared_wave)

		#no more waves
		if Game_Manager.wave_index >= waves.size():
			Signal_Bus.all_waves_cleared.emit()
			return

		await get_tree().create_timer(time_between_waves).timeout

		if Game_Manager.run_failed:
			return


#spawn every enemy in this wave, one every spawn_interval
func _spawn_wave(wave: WaveData) -> void:
	enemies_alive = 0

	for i in range(wave.count):
		_spawn_enemy(wave)

		#don't wait after the final enemy
		if i < wave.count - 1:
			await get_tree().create_timer(wave.spawn_interval).timeout

			if Game_Manager.run_failed:
				return


#instantiate one enemy and drop it just off screen
func _spawn_enemy(wave: WaveData) -> void:
	var node := wave.enemy_scene.instantiate()

	#anything that isnt an Entity is an authoring mistake
	if not node is Entity:
		push_error(
			"[Waves] %s does not inherit Entity"
			% wave.enemy_scene.resource_path
		)
		node.queue_free()
		return

	var enemy := node as Entity

	#the group is what says this one counts for the wave, player bees are
	#Entities too and stay out of it
	enemy.add_to_group("wave_enemy")
	enemies_alive += 1

	get_tree().current_scene.add_child(enemy)

	enemy.global_position = _random_spawn_position()

	#multiply not assign, so these survive retuning base stats
	enemy.health *= wave.health_multiplier
	enemy.speed *= wave.speed_multiplier


#take dead enemies out of the count
func _on_entity_died(entity: Entity) -> void:
	if entity == null or not is_instance_valid(entity):
		return

	#a dying player bee must not clear a wave
	if not entity.is_in_group("wave_enemy"):
		return

	#so a duplicate death signal cannot count twice
	entity.remove_from_group("wave_enemy")

	enemies_alive -= 1

	if enemies_alive <= 0:
		enemies_alive = 0
		wave_empty.emit()


#random point just off the edge of what the camera can see
func _random_spawn_position() -> Vector2:
	var camera := get_viewport().get_camera_2d()

	if camera == null:
		push_error("[Waves] No active Camera2D")
		return Vector2.ZERO

	#zoomed in means less world per pixel, so divide
	var half_size := (
		get_viewport().get_visible_rect().size
		* 0.5
		/ camera.zoom.x
	)

	var spawn_rect := Rect2(
		camera.get_screen_center_position() - half_size,
		half_size * 2.0
	).grow(spawn_margin)

	#pick one of the four edges, then a random spot along it
	match randi() % 4:
		0:
			return Vector2(
				randf_range(spawn_rect.position.x, spawn_rect.end.x),
				spawn_rect.position.y
			)

		1:
			return Vector2(
				spawn_rect.end.x,
				randf_range(spawn_rect.position.y, spawn_rect.end.y)
			)

		2:
			return Vector2(
				randf_range(spawn_rect.position.x, spawn_rect.end.x),
				spawn_rect.end.y
			)

		_:
			return Vector2(
				spawn_rect.position.x,
				randf_range(spawn_rect.position.y, spawn_rect.end.y)
			)
