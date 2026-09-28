@abstract class_name Upgrade extends Node2D

@export_enum("HEAD", "BODY", "EQUIPMENT") var upgrade_type : String = "BODY"

@onready var entity : Entity = get_parent()
func _ready():
	assert(entity is Entity, "ERROR: " + str(self) + " has a parent that is not an Entity")

#Initializes the upgrade and it's components
@abstract func init() -> void

#Prepares to upgrade to be removed
@abstract func exit() -> void
