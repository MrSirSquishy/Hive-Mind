extends Node2D
# health bar

@export var bar_size : Vector2 = Vector2(250, 24)
@export var height_above_body : float = 200.0

@onready var body : Body = get_parent()
@onready var progress_bar : ProgressBar = $ProgressBar


func _ready() -> void:
	#setup with body and connect 
	top_level = true
	progress_bar.position = -bar_size / 2.0
	progress_bar.size = bar_size
	body.health_changed.connect(_on_health_changed)
	if not body.is_node_ready():
		await body.ready
	_on_health_changed(body.health, body.max_health)


func _process(_delta : float) -> void:
	#keeps health bar with the body
	global_position = body.global_position + Vector2(0, -height_above_body)


func _on_health_changed(current_health : float, maximum_health : float) -> void:
	#updates health bar
	progress_bar.max_value = maximum_health
	progress_bar.value = current_health
