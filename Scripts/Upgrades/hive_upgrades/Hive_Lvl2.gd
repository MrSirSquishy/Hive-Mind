extends Hive_Upgrade

func init(hive : Hive) -> void:
	#Removes default sprite
	var sprite : Node = hive.get_node_or_null("Sprite")
	if sprite and sprite is Sprite2D:
		sprite.queue_free()
		
	#Upgrades health
	hive.max_health *= 2
	hive.health = hive.max_health

func exit(hive : Hive) -> void:
	pass
