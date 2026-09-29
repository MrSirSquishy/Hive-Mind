@abstract class_name Entity extends RigidBody2D
#Made as parent for Bee and Enemy classes

@onready var sprite_handler : Sprite_Handler = get_node("Sprite")

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

var is_dead : bool = false

## Damage
#anything that can hurt should go through here so it all behaves the same
func take_damage(amount : float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0.0:
		die()

#call this instead of queue_free, Game_Manager counts entity_died
func die() -> void:
	if is_dead:
		return
	is_dead = true
	Signal_Bus.entity_died.emit(self)
	queue_free()
