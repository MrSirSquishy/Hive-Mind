@abstract class_name Entity extends RigidBody2D
#Made as parent for Bee and Enemy classes

#How strong the repel force is between colliding objects
@export var repelForce : float = 10
#The area2D to use as the collider
@export var collider : Area2D

#damping. Higher values slow it down faster, 0 is frictonless
@export var damping : float = 0.1
#movement speed
@export var speed : float = 1000.0

@onready var colliding_areas : Array[Area2D]
@onready var velocity : Vector2 = Vector2(0, 0)




@abstract func _ready() -> void

@abstract func _process(dt: float) -> void

@abstract func _physics_process(dt: float) -> void
