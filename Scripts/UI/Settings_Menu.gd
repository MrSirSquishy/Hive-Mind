extends CanvasLayer

var was_paused: bool = false
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

@onready var volume_slider: HSlider = $Menu/Center/Panel/Margin/Options/Volume/Slider
@onready var volume_label: Label = $Menu/Center/Panel/Margin/Options/Volume/Value
@onready var fullscreen_button: CheckButton = $Menu/Center/Panel/Margin/Options/Fullscreen
@onready var vsync_button: CheckButton = $Menu/Center/Panel/Margin/Options/VSync

func _ready() -> void:
	was_paused = get_tree().paused
	previous_mouse_mode = Input.mouse_mode
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	volume_slider.set_value_no_signal(Global.master_volume)
	volume_label.text = "%d%%" % roundi(Global.master_volume)
	fullscreen_button.set_pressed_no_signal(Global.fullscreen)
	vsync_button.set_pressed_no_signal(Global.vsync_enabled)
	$Menu/Center/Panel/Margin/Options/Back.grab_focus()

func _exit_tree() -> void:
	get_tree().paused = was_paused
	Input.set_mouse_mode(previous_mouse_mode)

func _on_volume_changed(value: float) -> void:
	Global.master_volume = value
	volume_label.text = "%d%%" % roundi(value)
	Global.apply_settings()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	Global.fullscreen = toggled_on
	Global.apply_settings()

func _on_vsync_toggled(toggled_on: bool) -> void:
	Global.vsync_enabled = toggled_on
	Global.apply_settings()

func _on_back_pressed() -> void:
	Global.save_settings()
	queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
