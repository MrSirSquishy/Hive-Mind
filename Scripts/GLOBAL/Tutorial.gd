extends Node

signal finished

const MESSAGES: PackedStringArray = [
	"1/5  Move the camera with WASD or the arrow keys, or drag with the right mouse button.",
	"2/5  Zoom with the mouse wheel.",
	"3/5  Press H to find the hive, then press E and click a bee to select it.",
	"4/5  Press G or choose Defend Area, then left-click and drag a circle for the bee to guard.",
	"5/5  Press E, click a bee, then press R to defend the hive.",
]

const NEEDS: PackedStringArray = ["pan", "zoom", "select", "command", "defend"]

var active: bool = false
var step: int = 0

func start() -> void:
	Global.reset_run()
	get_tree().paused = false
	Engine.time_scale = 1.0
	active = true
	step = 0
	if get_tree().change_scene_to_file("res://Scenes/Worlds/world.tscn") != OK:
		stop()

func stop() -> void:
	active = false
	step = 0

func show_current() -> void:
	if active:
		Signal_Bus.toast_requested.emit(MESSAGES[step], true)

func done(action: String) -> void:
	if not active or NEEDS[step] != action:
		return
	step += 1
	if step == NEEDS.size():
		active = false
		finished.emit()
		Signal_Bus.toast_requested.emit("Tutorial complete. Wave 1 begins!", false)
		return
	show_current()

func bees_selected(entities: Array[Entity]) -> void:
	# enemy clicks don't count
	for entity: Entity in entities:
		if entity is Bee:
			done("select")
			return
