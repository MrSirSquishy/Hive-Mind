@abstract class_name Entity extends RigidBody2D
#Made as parent for Bee and Enemy classes


@export var health : float = 10.0

@export_group("Movement")
@export var speed : float = 10000.0
@export var turn_speed : float = 50000000.0

@export_group("AI")
#How close it should be to the target_position to be considered reached
@export var target_margin : float = 200
#How close it should be to the target_position to begin slowing down
@export var target_slowdown_margin : float = 2000
#The Area2D that defines what the bee is aware of/can see
@export var awareness_area : Area2D = get_node_or_null("Awareness_Area")


@onready var state : String	= "IDLE"
@onready var target_position : Vector2 = position

@onready var upgrades : Dictionary = {
	"HEAD" : null,
	"BODY" : null,
	"EQUIPMENT" : null
}
