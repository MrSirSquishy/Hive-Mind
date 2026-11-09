extends Node

#hive upgrades applied
var hive_max_health_bonus: float = 0.0
var hive_defense_bonus: float = 0.0

var master_volume: float = 100.0
var fullscreen: bool = false
var vsync_enabled: bool = true

var highest_wave: int = 0
var _overlay: Node = null
var _overlay_was_paused: bool = false
var _overlay_previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_HIDDEN

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config: ConfigFile = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume = clampf(config.get_value("audio", "master_volume", 100.0), 0.0, 100.0)
		fullscreen = config.get_value("display", "fullscreen", false)
		vsync_enabled = config.get_value("display", "vsync_enabled", true)
	apply_settings()
	load_highest_wave()

func load_highest_wave() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	if config.load("user://progress.cfg") == OK:
		highest_wave = int(
			config.get_value("progress", "highest_wave", 0)
		)
func register_wave_reached(wave: int) -> void:
	if wave <= highest_wave:
		return
		
	highest_wave = wave
	
	var config: ConfigFile = ConfigFile.new()
	config.set_value("progress", "highest_wave", highest_wave)
	
	var error: Error = config.save("user://progress.cfg")

	if error != OK:
		push_error("Could not save highest wave")

func apply_settings() -> void:
	AudioServer.set_bus_volume_linear(0, master_volume / 100.0)
	AudioServer.set_bus_mute(0, master_volume <= 0.0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)

func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "vsync_enabled", vsync_enabled)
	var error: Error = config.save("user://settings.cfg")
	if error != OK:
		push_error("Could not save settings: %s" % error_string(error))

func open_settings() -> void:
	var host: Node = get_tree().current_scene
	if host == null:
		return
	if host.get_node_or_null("SettingsMenu") != null:
		return
	var packed_scene: PackedScene = load("res://Scenes/UI/settings_menu.tscn") as PackedScene
	if packed_scene == null:
		push_error("Could not load the settings menu")
		return
	var settings_menu: CanvasLayer = packed_scene.instantiate()
	settings_menu.tree_exited.connect(_focus_first_button, CONNECT_DEFERRED)
	host.add_child(settings_menu)

func open_overlay(scene_path: String) -> void:
	var host: Node = get_tree().current_scene
	if host == null:
		return
	var layer: Node = host.get_node_or_null("OverlayLayer")
	if layer == null:
		push_error("Current scene has no OverlayLayer to host %s" % scene_path)
		return
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Could not load overlay scene %s" % scene_path)
		return
	close_overlay()
	_overlay_was_paused = get_tree().paused
	_overlay_previous_mouse_mode = Input.mouse_mode
	_overlay = packed_scene.instantiate()
	layer.add_child(_overlay)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_focus_first_button()

func close_overlay() -> void:
	if not is_instance_valid(_overlay):
		_overlay = null
		return
	_overlay.queue_free()
	_overlay = null
	get_tree().paused = _overlay_was_paused
	Input.set_mouse_mode(_overlay_previous_mouse_mode)

func _focus_first_button() -> void:
	if not is_instance_valid(_overlay) or not _overlay.is_inside_tree() or _overlay.is_queued_for_deletion():
		return
	for child: Node in _overlay.find_children("*", "Button", true, false):
		var button: Button = child as Button
		if button != null and not button.disabled and button.is_visible_in_tree():
			button.grab_focus()
			return

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(_overlay) or not event.is_action_pressed("ui_cancel"):
		return
	var host: Node = get_tree().current_scene
	if host != null and host.get_node_or_null("SettingsMenu") != null:
		return
	get_viewport().set_input_as_handled()
	close_overlay()

func reset_run() -> void:
	Honey_Manager.honey = 0
	hive_max_health_bonus = 0.0
	hive_defense_bonus = 0.0
