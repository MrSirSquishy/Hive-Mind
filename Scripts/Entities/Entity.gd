@abstract class_name Entity extends RigidBody2D
#Made as parent for Bee and Enemy classes


#movement speed
@export var speed : float = 1000.0



@abstract func _ready() -> void

@abstract func _process(dt: float) -> void

@abstract func _physics_process(dt: float) -> void


