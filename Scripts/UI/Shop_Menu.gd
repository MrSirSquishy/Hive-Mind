extends Control

class Upgrade_Button:
	var button : Button
	var label : Label
	var upgrade_scene : PackedScene
	
	func _init(_button : Button) -> void:
		button = _button
		label = button.get_node("Label")
		
	func set_upgrade(upgrade : PackedScene) -> void:
		upgrade_scene = upgrade
		label.text = upgrade_scene.resource_path.get_file().get_basename()

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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

	

func _on_return_to_hive_button_pressed() -> void:
	Signal_Bus.close_shop.emit()
	Global.close_overlay()
