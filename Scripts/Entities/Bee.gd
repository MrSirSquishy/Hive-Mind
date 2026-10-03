class_name Bee extends Entity
var is_dead = false
signal died
# tells game manager "im dead" then removes itself
func kill():
	if is_dead:
		return
	
	is_dead = true
	died.emit()
	super.kill() 
