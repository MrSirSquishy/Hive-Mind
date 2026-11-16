class_name Enemy extends Entity
@export var honey_on_kill: int = 10 #needed for honey addition 
#(needs to be different for different enemies eventually)

func _init() -> void:
	died.connect(_award_honey)

func _award_honey() -> void:
	Honey_Manager.add_honey(honey_on_kill)
