extends Control

class Upgrade_Button:
	var button : Button
	var label : Label
	var price_label: Label
	var upgrade : Upgrade
	
	func _init(_button : Button) -> void:
		button = _button
		label = button.get_node("Label")
		price_label = button.get_node("Price_Label")
		button.pressed.connect(on_press)
		
	func on_press() -> void:
		if Honey_Manager.can_afford(RARITY_PRICES[upgrade.rarity]):
			Signal_Bus.toast_requested.emit("Pick a bee to apply the upgrade to!", false)
			Signal_Bus.upgrade_signal.emit(upgrade)
			Signal_Bus.upgrade_finished_signal.connect(upgrade_finished)
		else:
			Signal_Bus.toast_requested.emit("Not enough honey!", false)
		
	func upgrade_finished(is_canceled : bool = false) -> void:
		if is_canceled:
			button.show()
			return
		Honey_Manager.spend_honey(RARITY_PRICES[upgrade.rarity])
		upgrade = null
		button.hide()
		
	
	func set_upgrade(upgrade_scene : PackedScene) -> void:
		upgrade = upgrade_scene.instantiate()
		if upgrade.icon:
			button.icon = upgrade.icon
		label.text = upgrade.name
		price_label.text = str(RARITY_PRICES[upgrade.rarity]) + " Honey"
		button.show()
		if Signal_Bus.upgrade_finished_signal.is_connected(upgrade_finished):
			Signal_Bus.upgrade_finished_signal.disconnect(upgrade_finished)
		

@onready var shop_item_buttons : Array[Upgrade_Button] = [
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade1),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade2),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade3),
	Upgrade_Button.new($MarginContainer/VBoxContainer/HBoxContainer/Upgrade4)
]


const UPGRADE_DIRECTORY : String = "res://Scenes/Upgrades/"
const RARITY_WEIGHTS : Array[int] = [
	60, #COMMON
	25, #UNCOMMON
	12, #RARE
	3   #LEGENDARY
]
const RARITY_PRICES : Array[int] = [
	50,  #COMMON
	80, #UNCOMMON
	120,  #RARE
	200   #LEGENDARY
]

func load_upgrades(upgrade_scenes : Array[PackedScene], upgrade_rarities : Array[int]) -> void:
	# Lists resources in this folder only; subfolders aren't scanned.
	var files: PackedStringArray = ResourceLoader.list_directory(UPGRADE_DIRECTORY)

	for file_name: String in files:
		if file_name.get_extension().to_lower() != "tscn":
			continue

		var scene_path: String = UPGRADE_DIRECTORY.path_join(file_name)
		var packed_scene: PackedScene = load(scene_path) as PackedScene
		if packed_scene == null:
			continue

		var root: Node = packed_scene.instantiate()
		var upgrade: Upgrade = root as Upgrade

		if upgrade != null and upgrade.rarity >= 0 and upgrade.rarity < RARITY_WEIGHTS.size():
			upgrade_scenes.append(packed_scene)
			upgrade_rarities.append(upgrade.rarity)

		root.free()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func pick_weighted_index(upgrade_rarities: Array[int]) -> int:
	var total_weight: int = 0

	for rarity: int in upgrade_rarities:
		total_weight += RARITY_WEIGHTS[rarity]

	if total_weight <= 0:
		return -1

	var roll: int = rng.randi_range(1, total_weight)
	var running_weight: int = 0

	for i: int in range(upgrade_rarities.size()):
		running_weight += RARITY_WEIGHTS[upgrade_rarities[i]]
		if roll <= running_weight:
			return i

	return -1

func _ready() -> void:
	Signal_Bus.upgrade_signal.connect(_upgrade_signal)
	Signal_Bus.upgrade_finished_signal.connect(_upgrade_finished_signal)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	Signal_Bus.close_sub_menu.emit()
	rng.randomize()

	var upgrade_scenes: Array[PackedScene] = []
	var upgrade_rarities: Array[int] = []
	load_upgrades(upgrade_scenes, upgrade_rarities)

	var count: int = min(shop_item_buttons.size(), upgrade_scenes.size())
	for i: int in range(count):
		var picked_index: int = pick_weighted_index(upgrade_rarities)
		if picked_index == -1:
			break

		shop_item_buttons[i].set_upgrade(upgrade_scenes[picked_index])

		# Remove the pick so a scene can't appear twice.
		upgrade_scenes.remove_at(picked_index)
		upgrade_rarities.remove_at(picked_index)

func _upgrade_signal(_upgrade : Upgrade) -> void:
	hide()

func _upgrade_finished_signal(_is_canceled : bool = false) -> void:
	show()

func _on_return_to_hive_button_pressed() -> void:
	Signal_Bus.close_shop.emit()
	Global.close_overlay()
