class_name Detection_Area extends Area2D

@export var linked_entities : Array[Entity] = []

## This will prevent the area from freeing itself when no entities are linked
@export var persistent : bool = false

## If entities should focus on enemies nearest to the center of the detection
## area instead of nearest to them (good for the hive)
@export var priortize_center : bool = false

## This is the radius entities will typically use to get in the radius
@export var inner_radius : float = 500

@onready var collider : CollisionShape2D = get_node("Collider")
@onready var shape : CircleShape2D = collider.shape.duplicate()

## Functions

func init_area(pos : Vector2 = get_global_mouse_position(), radius : float = 1000, entity_array : Array[Entity] = []) -> void:
	position = pos
	set_radius(radius)
	inner_radius = radius/2
	#Note: set_detection_area appends the entity to the linked_entities array
	for entity : Entity in entity_array:
		entity.set_detection_area(self)
	
func remove_if_empty() -> void:
	if linked_entities.size() == 0:
		remove()
	
func remove() -> void:
	queue_free()

func get_radius() -> float:
	return shape.radius

func set_radius(radius : float) -> void:
	shape.radius = radius

## Active Functions

#Fixes the collider shape to prevent sharing the same shape resource
func _ready() -> void:
	collider.shape = shape
	
func _physics_process(_dt: float) -> void:
	if not persistent and linked_entities.size() == 0:
		#Gives delay before freeing
		await get_tree().create_timer(1.0).timeout
		if linked_entities.size() == 0:
			remove()
