class_name Detection_Area extends Area2D

@export var linked_entities : Array[Entity] = []

## This will prevent the area from freeing itself when no entities are linked
@export var persistent : bool = false

@onready var collider : CollisionShape2D = get_node("Collider")
@onready var shape : CircleShape2D = collider.shape


func _physics_process(_dt: float) -> void:
	if linked_entities.size() == 0:
		#Gives delay before freeing
		await get_tree().create_timer(1.0).timeout
		if linked_entities.size() == 0:
			queue_free()

func _on_body_entered(_body: Node2D) -> void:
	pass
