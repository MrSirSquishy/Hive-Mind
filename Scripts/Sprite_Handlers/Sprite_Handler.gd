class_name Sprite_Handler extends Sprite2D


@export var left_eye : Sprite2D
@export var left_pupil : Sprite2D
@export var right_eye : Sprite2D
@export var right_pupil : Sprite2D

@export_group("Eye Movement")
@export var eye_movement_factor : float = 10.0
@export var eye_movement_speed : float = 10.0


@onready var eye_dir : Vector2 = Vector2.ZERO
@onready var target_eye_dir : Vector2 = Vector2.ZERO
## Sets the eye positions based on a given dir. Use set_eye_dir for a smoother change.
func update_eye_dir(dir : Vector2) -> void:
	left_pupil.position = dir * eye_movement_factor
	right_pupil.position = left_pupil.position

## Sets the target eye offset in px. This is relative to the bee, and isn't immediate.
func set_eye_dir(dir : Vector2) -> Sprite_Handler:
	target_eye_dir = dir
	return self

## Animations

func play_attack_animation() -> void:
	pass

## Active Functions
func _ready() -> void:
	update_eye_dir(eye_dir)

func _physics_process(dt : float) -> void:
	# Interplates the eyes
	if (eye_dir - target_eye_dir).length() > 0.01:
		eye_dir = lerp(eye_dir, target_eye_dir, dt * eye_movement_speed)
		update_eye_dir(eye_dir)
	
