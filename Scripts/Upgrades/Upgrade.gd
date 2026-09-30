@abstract class_name Upgrade extends Node2D

@export_enum("HEAD", "BODY", "EQUIPMENT") var upgrade_type : String = "BODY"

#Initializes the upgrade and it's components
@abstract func init(entity : Entity) -> void

#Prepares to upgrade to be removed
@abstract func exit(entity : Entity) -> void

func physics_process_upgrade(entity : Entity, dt : float) -> void:
	pass
