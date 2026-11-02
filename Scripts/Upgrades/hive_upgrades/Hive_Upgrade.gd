@abstract class_name Hive_Upgrade extends Node2D

#Initializes the upgrade and it's components
@abstract func init(hive : Hive) -> void

#Prepares to upgrade to be removed
@abstract func exit(hive : Hive) -> void

func physics_process_upgrade(_hive : Hive, _dt : float) -> void:
	pass
