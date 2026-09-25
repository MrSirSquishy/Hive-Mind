extends Upgrade

@onready var gun_sprite : Sprite2D = get_node_or_null("gun_sprite")

func init() -> void:
	gun_sprite.reparent(parent.sprite_handler)

func exit() -> void:
	gun_sprite.reparent(self)
