extends Node

const MESSAGES: PackedStringArray = PackedStringArray([
	"Move the camera with WASD, or drag with the right mouse button.",
	"Zoom with the mouse wheel.",
	"Click a bee to select it.",
	"Give that bee a command. Press F to attack, or G to guard an area.",
	"Defend the hive. Press R, or choose Defend Hive.",
])

const NEEDS: PackedStringArray = PackedStringArray([
	"pan",
	"zoom",
	"select",
	"command",
	"defend",
])

var active: bool = false
var step: int = 0

func start() -> void:
	active = true
	step = 0

func stop() -> void:
	active = false

func show_current() -> void:
	if not active or step < 0 or step >= MESSAGES.size():
		return
	Signal_Bus.toast_requested.emit(MESSAGES[step], true)

func done(action: String) -> void:
	# only the current step counts
	if not active or step >= NEEDS.size() or NEEDS[step] != action:
		return
	step += 1
	if step >= MESSAGES.size():
		active = false
		Signal_Bus.toast_requested.emit("You're ready, have fun!", false)
		return
	show_current()

func bees_selected(entities: Array[Entity]) -> void:
	# enemy clicks don't count
	for entity: Entity in entities:
		if entity is Bee:
			done("select")
			return
