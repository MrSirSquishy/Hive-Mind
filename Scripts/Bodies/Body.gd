class_name Body extends RigidBody2D
#parent of Hive and Entity classes

signal health_changed(current_health: float, max_health: float)

##The team this entity is a part of, for example, "BEE" or "ENEMY" Entities will attack non-team members
@export var team : String = "NONE"

##Default Bee has 10.0 health for refernce
@export var max_health : float = 10.0
@onready var health : float = max_health

##This determines the approximate "size" (in px) of the entity for things like distance and closeness calculations. Default Bee 150 px for reference
@export var radius : float = 150


@onready var i_frame_dictionary : Dictionary[String, float] = {}



## Functions
func update_i_frames(dt : float) -> void:
	# Updates all sets of i_frames:
	for source : String in i_frame_dictionary.keys():
		i_frame_dictionary[source] -= dt
		# removes the i_frames if it's up
		if i_frame_dictionary[source] <= 0:
			i_frame_dictionary.erase(source)

## inflicts damage on the entity.
## [br]
## source_identifier and i_frames are to specify the local i_frames for an 
## entity or attack, defined by source_identifier. If the i_frames for the
## source_identifier aren't up, the entity does not take damage.
## [br]
## Returns weather or not the attack managed to hit
func damage(damage_amount : float, source_identifier : String, i_frames : float) -> bool:
	#checks if the i frames for the source are up, it not, no damage
	for source : String in i_frame_dictionary:
		if source == source_identifier:
			return false
	#If not found, then continue with the attack and add start the i_frames
	i_frame_dictionary.set(source_identifier, i_frames)
	
	#Plays a flash to indicate getting hit
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 3, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	#The actual damage dealing
	health = clampf(health - damage_amount, 0.0, max_health)
	health_changed.emit(health, max_health)
	if health <= 0:
		kill()
	
	return true

signal died
func kill() -> void:
	died.emit()
	queue_free()
