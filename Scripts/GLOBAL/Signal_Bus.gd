extends Node

# Global signals go here

signal world_clicked(global_position : Vector2)

signal trigger_cam_shake(strength : float, position : Vector2)

#Emit to immediately trigger next wave
signal skip_wave()
signal show_skip_wave_button()
signal hide_skip_wave_button()
