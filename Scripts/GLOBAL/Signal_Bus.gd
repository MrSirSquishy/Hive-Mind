extends Node

### Misc Signals

signal world_clicked(global_position : Vector2)

## entities will call this to get the default detection area of the hive
signal attach_default_detection_area(entity : Entity)


### Visual Effects Signals

signal trigger_cam_shake(strength : float, position : Vector2)


### Game Loop Signals

##Emit to immediately trigger next wave
signal skip_wave()
signal show_skip_wave_button()
signal hide_skip_wave_button()

signal game_over()


### UI signals
signal toast_requested(message: String, sticky: bool)

signal open_sub_menu(entity_array : Array[Entity])
signal close_sub_menu()

signal show_shop_button()
signal hide_shop_button()
signal close_shop()

signal open_upgrade_menu(target : Entity)
signal open_upgrade_menu_array(target: Array[Entity])
signal close_upgrade_menu() 

signal attack_signal()
signal defend_area_signal()
signal defend_hive_signal()
signal selection_signal()
