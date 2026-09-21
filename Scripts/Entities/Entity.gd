@abstract class_name Entity extends Node2D
#Made as parent for Bee and Enemy classes

#For soft collisions
@export var mass : float = 1.0;
@export var collider : Area2D

@abstract func _ready() -> void

@abstract func _process(dt: float) -> void

@abstract func _physics_process(dt: float) -> void
