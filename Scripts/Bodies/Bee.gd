class_name Bee extends Entity

@export var bee_name : String = ""

func _ready() -> void:
	if bee_name == "":
		bee_name = get_random_bee_name()
	super._ready()

func upgrade_health(amount: float) -> void:
	max_health += amount
	health += amount
	health_changed.emit(health, max_health)


static var bee_name_array : Array[String] = [
	"John Bee",
	"Grumble",
	"Beeatrice",
	"Mr. Bumble",
	"Mrs. Bumble",
	"Bumble Jr.",
	"Charles",
	"Beelzebub",
	"Marty McBee",
	"Buzz Aldrin",
	"Barry B. Benson",
	"Sarah",
	"Oliver",
	"Lilac",
	"Toyota Corola",
	"Stanley",
	"Bernard",
	"Vlad",
	"Abigail",
	"Hayden",
	"Cinder Block",
	"Daisy",
	"Clover",
	"Marigold",
	"Sunny",
	"Poppy",
	"Cocoa",
	"Cinnamon",
	"Nutmeg",
	"Yellow",
	"Flowery",
	"Hornet",
	"Grace",
	"Eva",
	"Vanilla",
	"Peaches",
	"Juniper",
	"Willow",
	"Pickle",
	"Madeline",
	"Ryan",
	"Beethoven",
	"Ivy"
]

## Resets back to the default detection area (the hive)
func reset_detection_area() -> void:
	Signal_Bus.attach_default_detection_area.emit(self)

static func get_random_bee_name() -> String:
	return bee_name_array[randi_range(0, bee_name_array.size() - 1)]
