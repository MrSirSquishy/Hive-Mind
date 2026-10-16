extends Node

#hive upgrades applied
var hive_max_health_bonus: float = 0.0
var hive_defense_bonus: float = 0.0

var master_volume: float = 100.0
var fullscreen: bool = false
var vsync_enabled: bool = true

func _ready() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume = clampf(config.get_value("audio", "master_volume", 100.0), 0.0, 100.0)
		fullscreen = config.get_value("display", "fullscreen", false)
		vsync_enabled = config.get_value("display", "vsync_enabled", true)
	apply_settings()

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
	var settings_menu: CanvasLayer = load("res://Scenes/UI/settings_menu.tscn").instantiate()
	get_tree().current_scene.add_child(settings_menu)

func reset_run() -> void:
	Honey_Manager.honey = 0
	hive_max_health_bonus = 0.0
	hive_defense_bonus = 0.0
