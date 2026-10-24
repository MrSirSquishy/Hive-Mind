extends Node

### Misc Signals

signal world_clicked(global_position : Vector2)


### Visual Effects Signals

signal trigger_cam_shake(strength : float, position : Vector2)


### Game Loop Signals

##Emit to immediately trigger next wave
signal skip_wave()
signal show_skip_wave_button()
signal hide_skip_wave_button()

signal game_over()


### UI signals

signal open_sub_menu(target : Entity)
signal open_sub_menu_array(target : Array[Entity])
signal close_sub_menu()

signal open_upgrade_menu(target : Entity)
signal open_upgrade_menu_array(target: Array[Entity])
signal close_upgrade_menu() 
