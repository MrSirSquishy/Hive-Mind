class_name Enemy extends Entity
@export var honey_on_kill: int = 10 #needed for honey addition 
#(needs to be different for different enemies eventually)

#Enemies add honey when killed
func kill() -> void:
	Honey_Manager.add_honey(honey_on_kill)
	super.kill()
