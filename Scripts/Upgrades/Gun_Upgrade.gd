extends Upgrade

@onready var gun_sprite : Sprite2D = get_node_or_null("gun_sprite")

func init(entity : Entity) -> void:
	gun_sprite.reparent(entity.sprite_handler)

func exit(_entity : Entity) -> void:
	gun_sprite.reparent(self)
