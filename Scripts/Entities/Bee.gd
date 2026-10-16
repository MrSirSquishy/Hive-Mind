class_name Bee extends Entity
signal bee_selected(bee: Node)   # Signals to the rest of the program which bee is selected

@onready var click_area: Area2D = $Click_Area

##needed for upgrades
var bee_damage: float = 10.0
var bee_attack_speed: float = 1.0
var bee_health: float = 10.0

func upgrade_damage(amount: float) -> void:
	bee_damage += amount

func upgrade_attack_speed(amount: float) -> void:
	bee_attack_speed += amount

func upgrade_health(amount: float) -> void:
	bee_health += amount

func _ready() -> void:
	click_area.input_event.connect(_on_click_area_input_event)


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("This bee was clicked")
			bee_selected.emit(self)          # Tells the world which bee was pressed on
