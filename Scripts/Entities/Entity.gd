@abstract class_name Entity extends RigidBody2D
#Made as parent for Bee and Enemy classes


#movement speed
@export var speed : float = 10000.0
func get_selection_info() -> Dictionary:
		return {
			"type": "entity",
			"ref": self,
			"pos": global_position,
		}


@abstract func _ready() -> void

@abstract func _process(dt: float) -> void

@abstract func _physics_process(dt: float) -> void
