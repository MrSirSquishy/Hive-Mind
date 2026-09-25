extends CanvasLayer
#scene fixxed ui, ignores camera
var _panel: PanelContainer # Main box
var _title: Label
var _info: Label 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer = 10
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.position = Vector2(-260.0, 16.0)
	_panel.custom_minimum_size = Vector2(244.0, 0.0)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel) 
	var vbox: VBoxContainer = VBoxContainer.new()
	_title = Label.new()
	_title.text = "No selection"
	vbox.add_child(_title)
	_info = Label.new()
	_info.text = ""
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART #wraps long text
	vbox.add_child(_info)
	Signal_Bus.area_scanned.connect(_on_area_scanned)
	hide_panel()
# Called every frame. 'delta' is the elapsed time since the previous frame.

#called _on_area_scanned()
func _on_area_scanned(picked: Node2D, world_pos: Vector2) -> void:
	if picked == null:
		hide_panel()
		return
		
		if picked is Bee:
			show_bee(picked as Bee) # 
	else:
			#fallback for future
		_title.text = picked.name
		_info.text = "pos: %s" % str(picked.global_position)
		_panel.show()
		
func show_bee(b: Bee) -> void:
	_title.text = "Bee: %s" % b.name
	_info.text = "pos: %s\nspeed: %s" % [str(b.global_position), str(b.speed)]
	_panel.show()
	
func hide_panel() -> void:
	_panel.hide() #hidden but still listening
