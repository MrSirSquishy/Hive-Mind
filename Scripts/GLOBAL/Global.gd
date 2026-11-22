extends Node

#hive upgrades applied
var hive_max_health_bonus: float = 0.0
var hive_defense_bonus: float = 0.0

var master_volume: float = 100.0
var fullscreen: bool = false
var vsync_enabled: bool = true

var highest_wave: int = 0
var _overlay: Node = null
var _overlay_previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _overlay_is_shop: bool = false
#var _overlay_was_paused: bool = false
#var _overlay_previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_HIDDEN

var activity_was_frozen : bool = false
var freeze_activity : bool = false

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

const SHOP_SCENE_PATH: String = "res://Scenes/UI/shop_menu.tscn"

func open_overlay(scene_path: String) -> void:
	var host: Node = get_tree().current_scene
	if host == null:
		return

	if _overlay_is_shop and is_instance_valid(_overlay):
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
	activity_was_frozen = freeze_activity
	freeze_activity = true
	_overlay_previous_mouse_mode = Input.mouse_mode
	_overlay_is_shop = scene_path == SHOP_SCENE_PATH
	_overlay = packed_scene.instantiate()
	layer.add_child(_overlay)

func update_world_cursor() -> void:
	var host: Node = get_tree().current_scene
	if not is_instance_valid(host):
		return
	var ui: Node = host.get_node_or_null("UI")
	if ui == null or is_instance_valid(_overlay) or host.get_node_or_null("SettingsMenu") != null or get_tree().paused:
		return
	for menu_name: String in ["EntitySubMenu", "UpgradeMenu", "HiveUpgradeMenu"]:
		var menu: CanvasItem = ui.get_node_or_null(menu_name) as CanvasItem
		if is_instance_valid(menu) and menu.is_visible_in_tree():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func close_overlay() -> void:
	if not is_instance_valid(_overlay):
		_overlay = null
		_overlay_is_shop = false
		return
	_overlay.queue_free()
	_overlay = null
	_overlay_is_shop = false
	freeze_activity = activity_was_frozen
	Input.set_mouse_mode(_overlay_previous_mouse_mode)
	call_deferred("update_world_cursor")

func _focus_first_button() -> void:
	if not is_instance_valid(_overlay) or not _overlay.is_inside_tree() or _overlay.is_queued_for_deletion():
		return
	for child: Node in _overlay.find_children("*", "Button", true, false):
		var button: Button = child as Button
		if button != null and not button.disabled and button.is_visible_in_tree():
			button.grab_focus()
			return

func finish_shop_overlay() -> void:
	if not _overlay_is_shop or not is_instance_valid(_overlay):
		return
	Signal_Bus.close_shop.emit()
	close_overlay()

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(_overlay) or not event.is_action_pressed("ui_cancel"):
		return
	var host: Node = get_tree().current_scene
	if host != null and host.get_node_or_null("SettingsMenu") != null:
		return
	get_viewport().set_input_as_handled()
	if _overlay_is_shop:
		if _overlay is CanvasItem and not (_overlay as CanvasItem).visible:
			Signal_Bus.upgrade_finished_signal.emit(true)
		else:
			finish_shop_overlay()
		return
	close_overlay()

const RUN_SAVE_PATH: String = "user://hive_run.cfg"
var loaded_run: Dictionary = {}

func has_saved_run() -> bool:
	var config: ConfigFile = ConfigFile.new()
	return config.load(RUN_SAVE_PATH) == OK and int(config.get_value("run", "completed_wave", -1)) >= 1

func load_run() -> bool:
	var config: ConfigFile = ConfigFile.new()
	if config.load(RUN_SAVE_PATH) != OK:
		return false
	var completed_wave: int = int(config.get_value("run", "completed_wave", -1))
	if completed_wave < 1:
		return false
	loaded_run = {
		"completed_wave": completed_wave,
		"honey": maxi(0, int(config.get_value("run", "honey", 0))),
		"bee_count": maxi(0, int(config.get_value("run", "bee_count", 0))),
		"hive_health": float(config.get_value("run", "hive_health", 1.0)),
		"hive_max_health_bonus": float(config.get_value("run", "hive_max_health_bonus", 0.0)),
		"hive_defense_bonus": float(config.get_value("run", "hive_defense_bonus", 0.0))
	}
	reset_run(false)
	Honey_Manager.honey = loaded_run["honey"]
	hive_max_health_bonus = loaded_run["hive_max_health_bonus"]
	hive_defense_bonus = loaded_run["hive_defense_bonus"]
	return true

func save_run(completed_wave: int, bee_count: int, hive_health: float) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("run", "completed_wave", completed_wave)
	config.set_value("run", "honey", Honey_Manager.honey)
	config.set_value("run", "bee_count", bee_count)
	config.set_value("run", "hive_health", hive_health)
	config.set_value("run", "hive_max_health_bonus", hive_max_health_bonus)
	config.set_value("run", "hive_defense_bonus", hive_defense_bonus)
	var error: Error = config.save(RUN_SAVE_PATH)
	if error != OK:
		push_error("Could not save hive: %s" % error_string(error))

func reset_run(clear_save: bool = true) -> void:
	Honey_Manager.honey = 0
	hive_max_health_bonus = 0.0
	hive_defense_bonus = 0.0
	if clear_save:
		loaded_run.clear()
		if FileAccess.file_exists(RUN_SAVE_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_SAVE_PATH))
