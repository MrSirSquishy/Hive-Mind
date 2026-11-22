class_name UpgradeOptionRow extends PanelContainer

@onready var title_label: Label = $Padding/Column/Header/Title
@onready var icon_rect: TextureRect = $Padding/Column/Header/Icon
@onready var description_label: RichTextLabel = $Padding/Column/Description
@onready var value_label: Label = $Padding/Column/Actions/Value
@onready var purchase_button: Button = $Padding/Column/Actions/Buy
@onready var reason_label: Label = $Padding/Column/Reason

func _ready() -> void:
    var row_style: StyleBoxFlat = StyleBoxFlat.new()
    row_style.bg_color = Color("#fff4dc")
    row_style.border_color = Color("#dfc699")
    row_style.set_border_width_all(1)
    row_style.set_corner_radius_all(13)
    add_theme_stylebox_override("panel", row_style)

    var normal_style: StyleBoxFlat = StyleBoxFlat.new()
    normal_style.bg_color = Color("#efbe6b")
    normal_style.set_corner_radius_all(10)
    normal_style.set_content_margin_all(6)
    purchase_button.add_theme_stylebox_override("normal", normal_style)

    var hover_style: StyleBoxFlat = normal_style.duplicate()
    hover_style.bg_color = Color("#ffce7e")
    purchase_button.add_theme_stylebox_override("hover", hover_style)
    purchase_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var pressed_style: StyleBoxFlat = normal_style.duplicate()
    pressed_style.bg_color = Color("#d99c4d")
    purchase_button.add_theme_stylebox_override("pressed", pressed_style)

    var disabled_style: StyleBoxFlat = normal_style.duplicate()
    disabled_style.bg_color = Color("#dcd1bc")
    purchase_button.add_theme_stylebox_override("disabled", disabled_style)

func configure(title: String, description: String, next_value: String, cost: int, unavailable_reason: String = "", icon: Texture2D = null) -> void:
    title_label.text = title
    description_label.text = "[i]%s[/i]" % description
    value_label.text = next_value
    icon_rect.texture = icon
    icon_rect.visible = icon != null
    purchase_button.text = "%d honey" % cost
    purchase_button.disabled = not unavailable_reason.is_empty()
    purchase_button.tooltip_text = unavailable_reason if not unavailable_reason.is_empty() else "%s — %d honey" % [title, cost]
    reason_label.visible = not unavailable_reason.is_empty()
    reason_label.text = unavailable_reason
