@abstract class_name Upgrade extends Node2D

@export var icon : Texture2D
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("HEAD", "BODY", "EQUIPMENT") var upgrade_type : String = "BODY"

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}
@export var rarity : Rarity = Rarity.COMMON

#Initializes the upgrade and it's components
@abstract func init(entity : Entity) -> void

#Prepares to upgrade to be removed
@abstract func exit(entity : Entity) -> void

func physics_process_upgrade(_entity : Entity, _dt : float) -> void:
	pass
