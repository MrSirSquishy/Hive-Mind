extends Control

@onready var honey_label: Label = $HoneyLabel


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_return_to_hive_button_pressed() -> void:
	Global.close_overlay()


func _on_exit_to_menu_button_pressed() -> void:
	Global.close_overlay()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_honey_button_pressed() -> void:
	Honey_Manager.add_honey(1000)
