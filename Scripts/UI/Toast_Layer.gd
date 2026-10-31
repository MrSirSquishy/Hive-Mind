extends CanvasLayer

@onready var toast_panel: PanelContainer = $Root/TopRow/ToastPanel
@onready var message_label: Label = $Root/TopRow/ToastPanel/Message

var active_tween: Tween

func _ready() -> void:
	layer = 75
	process_mode = Node.PROCESS_MODE_ALWAYS

	Signal_Bus.toast_requested.connect(show_toast)

	toast_panel.hide()

func show_toast(message: String) -> void:
	if is_instance_valid(active_tween):
		active_tween.kill()

	message_label.text = message

	toast_panel.modulate.a = 0.0
	toast_panel.show()

	active_tween = create_tween()

	active_tween.tween_property(
		toast_panel, "modulate:a", 1.0, 0.2
	)
	active_tween.tween_interval(3.0)

	active_tween.tween_property(
		toast_panel, "modulate:a" ,0.0, 0.4
	)

	active_tween.tween_callback(toast_panel.hide)

