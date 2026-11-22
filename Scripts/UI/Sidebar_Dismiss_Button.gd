extends Button

signal dismissed

@onready var _panel: Control = get_parent()

var _slide: Tween
var _resting_left: float
var _resting_right: float

func _ready() -> void:
	pressed.connect(_slide_out)

func is_sliding() -> bool:
	return _slide != null

func reset_slide() -> void:
	if _slide == null:
		return
	_slide.kill()
	_slide = null
	_panel.offset_left = _resting_left
	_panel.offset_right = _resting_right

func _slide_out() -> void:
	if is_sliding():
		return
	_resting_left = _panel.offset_left
	_resting_right = _panel.offset_right
	var distance: float = get_viewport_rect().end.x - get_global_rect().position.x
	_slide = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_slide.tween_property(_panel, "position:x", _panel.position.x + distance, 0.18)
	_slide.tween_callback(dismissed.emit)
