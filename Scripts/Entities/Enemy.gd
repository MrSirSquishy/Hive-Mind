class_name Enemy extends Entity
@export var honey_on_kill: int = 10 #needed for honey addition 
#(needs to be different for different enemies eventually)

#Enemies add honey when killed
func kill() -> void:
	Honey_Manager.add_honey(honey_on_kill)
	super.kill()

func _ready() -> void:
	super._ready() # let Entity do its normal setup first
	# Bees follow mouse clicks, enemies should not
	if Signal_Bus.world_clicked.is_connected(set_target_position):
		Signal_Bus.world_clicked.disconnect(set_target_position)
