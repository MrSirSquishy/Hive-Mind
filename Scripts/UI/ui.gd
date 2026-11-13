extends Control

@onready var honey_label: Label = $HoneyLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float) -> void:
	pass

func _ready() -> void:
	Honey_Manager.honey_changed.connect(_on_honey_changed)
	_on_honey_changed(Honey_Manager.honey)

func _on_honey_changed(new_amount: int) -> void:
	honey_label.text = "Honey: %d" % new_amount


@onready var skip_wave: Button = $Skip_Wave
@onready var shop_button: Button = $ShopButton

## Signals
func _init() -> void:
	Signal_Bus.show_skip_wave_button.connect(_show_skip_wave_button)
	Signal_Bus.hide_skip_wave_button.connect(_hide_skip_wave_button)
	Signal_Bus.show_shop_button.connect(_show_shop_button)
	Signal_Bus.hide_shop_button.connect(_hide_shop_button)
	
func _show_skip_wave_button() -> void:
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(skip_wave, "offset_transform_position", Vector2(0, 0), 1)

func _hide_skip_wave_button() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(skip_wave, "offset_transform_position", Vector2(-500, 0), 0.5)

func _show_shop_button() -> void:
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(shop_button, "offset_transform_position", Vector2(0, 0), 1)

func _hide_shop_button() -> void:
	shop_button.offset_transform_position = Vector2(0, -300)
	#var tween : Tween = get_tree().create_tween()
	#tween.tween_property(shop_button, "offset_transform_position", Vector2(0, -300), 0.5)
