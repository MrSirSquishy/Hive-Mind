class_name Enemy extends Entity

signal died
# tells game manager "im dead" then removes itself
func die():
	died.emit()
	queue_free()

func _ready():
	super._ready() # let Entity do its normal setup first
	# Bees follow mouse clicks, enemies should not
	if Signal_Bus.world_clicked.is_connected(set_target_position):
		Signal_Bus.world_clicked.disconnect(set_target_position)
