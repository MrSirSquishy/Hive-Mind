@abstract class_name Entity extends Node2D
#Made as parent for Bee and Enemy classes

#For soft collisions
@export var mass : float = 1.0;
@export var collider : Area2D

@onready var colliding_areas : Array[Area2D]

#movement speed
@export var speed : float = 10.0


@abstract func _ready() -> void

@abstract func _process(dt: float) -> void

func _physics_process(dt: float) -> void:
	var overlapping_areas : Array[Area2D] = collider.get_overlapping_areas()
	for area in overlapping_areas:
		soft_collision(area, dt)

func soft_collision(colliding_area : Area2D, dt : float) -> void:
	pass
