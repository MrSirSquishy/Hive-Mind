extends Control

@onready var honey_label: Label = $HoneyLabel
@onready var initialZoom : float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale = 1/get_parent().zoom.x * Vector2.ONE * initialZoom

func _ready() -> void:
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	_on_honey_changed(Honey_Manager.honey)
	initialZoom = get_parent().zoom.x
	

func _on_honey_changed(new_amount: int) -> void:
	honey_label.text = "Honey: %d" % new_amount
