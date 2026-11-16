extends Detection_Area
## variant of Detection_Area that has a visual circle indicating it's area

@export var color : Color = Color(1.0, 0.722, 0.318, 0.247)
@export var stroke_color : Color = Color(1.0, 0.722, 0.318)

var is_being_removed : bool = false

func _physics_process(dt: float) -> void:
	if is_being_removed: return
	super._physics_process(dt)

func _process(_dt: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, shape.radius, color)
	draw_circle(Vector2.ZERO, shape.radius, stroke_color, false, 32)

func remove() -> void:
	if is_being_removed: return
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	# Rapier requires a positive radius until the area is freed.
	tween.tween_property(shape, "radius", 0.01, 0.4)
	
	is_being_removed = true
	await tween.finished
	queue_free()
	
