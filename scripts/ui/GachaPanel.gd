extends Control
class_name GachaPanel
## Gacha UI — pull single / x10, display result cards, back to world map.
## GachaEngine (Autoload) handles gem cost, pity, server RPC, and guest fallback.

@onready var _lbl_title:  Label          = $Header/Title
@onready var _lbl_gems:   Label          = $Header/GemLabel
@onready var _lbl_pity:   Label          = $Header/PityLabel
@onready var _results:    HFlowContainer = $ResultContainer
@onready var _lbl_status: Label          = $StatusLabel
@onready var _btn_pull1:  Button         = $ButtonRow/BtnPull1
@onready var _btn_pull10: Button         = $ButtonRow/BtnPull10
@onready var _btn_close:  Button         = $BtnClose

const RARITY_COLOR := {
	"common":    Color("#9d97b8"),
	"uncommon":  Color("#4fae6e"),
	"rare":      Color("#3f8fe0"),
	"epic":      Color("#a060e0"),
	"legendary": Color("#e0a030"),
	"mythic":    Color("#e0512f"),
}
const RARITY_TH := {
	"common": "ธรรมดา", "uncommon": "ไม่ธรรมดา", "rare": "หายาก",
	"epic": "มหากาพย์", "legendary": "ตำนาน", "mythic": "เทพปกรณัม",
}
const TYPE_ICON := {
	"skill_node": "◈", "weapon": "⚔", "armor": "🛡", "rune": "◉", "ore": "⬡",
}


func _ready() -> void:
	_lbl_title.text   = tr("GACHA_TITLE")
	_btn_pull1.text   = tr("GACHA_BTN_PULL1")
	_btn_pull10.text  = tr("GACHA_BTN_PULL10")
	_btn_close.text   = tr("GACHA_BTN_CLOSE")
	_lbl_status.text  = ""
	_results.visible  = false
	_update_header()
	_btn_pull1.pressed.connect(_on_pull1)
	_btn_pull10.pressed.connect(_on_pull10)
	_btn_close.pressed.connect(_on_close)
	GachaEngine.pull_completed.connect(_on_pull_completed)
	GachaEngine.pull_failed.connect(_on_pull_failed)


func _exit_tree() -> void:
	if GachaEngine.pull_completed.is_connected(_on_pull_completed):
		GachaEngine.pull_completed.disconnect(_on_pull_completed)
	if GachaEngine.pull_failed.is_connected(_on_pull_failed):
		GachaEngine.pull_failed.disconnect(_on_pull_failed)


func _update_header() -> void:
	_lbl_gems.text = "💎 %d" % GameState.gems
	_lbl_pity.text = "Pity: %d / 50" % GameState.gacha_pity


# ---------------------------------------------------------------------------
# Pull handlers
# ---------------------------------------------------------------------------

func _on_pull1() -> void:
	_lbl_status.text = ""
	_set_pulling(true)
	GachaEngine.pull_single()


func _on_pull10() -> void:
	_lbl_status.text = ""
	_set_pulling(true)
	GachaEngine.pull_multi()


func _on_pull_completed(items: Array) -> void:
	_set_pulling(false)
	_update_header()
	_show_results(items)


func _on_pull_failed(message: String) -> void:
	_set_pulling(false)
	_lbl_status.text     = message
	_lbl_status.modulate = Color("#ff6666")


func _set_pulling(active: bool) -> void:
	_btn_pull1.disabled  = active
	_btn_pull10.disabled = active
	_btn_close.disabled  = active
	if active:
		_lbl_status.text     = tr("GACHA_PULLING")
		_lbl_status.modulate = Color.WHITE

# ---------------------------------------------------------------------------
# Result display
# ---------------------------------------------------------------------------

func _show_results(items: Array) -> void:
	for child in _results.get_children():
		child.queue_free()
	for item in items:
		_results.add_child(_make_card(item))
	_results.visible = true


func _make_card(item: Dictionary) -> PanelContainer:
	var rarity: String = item.get("rarity", "common")
	var col: Color = RARITY_COLOR.get(rarity, Color.WHITE)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(106, 126)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 3)
	panel.add_child(vbox)

	# Type icon (colored by rarity)
	var lbl_icon := Label.new()
	lbl_icon.text = TYPE_ICON.get(item.get("item_type", ""), "●")
	lbl_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_icon.modulate = col
	lbl_icon.add_theme_font_size_override("font_size", 30)
	vbox.add_child(lbl_icon)

	# Item name
	var lbl_name := Label.new()
	lbl_name.text = item.get("name_th", item.get("name_en", "—"))
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_name)

	# Rarity label
	var lbl_rar := Label.new()
	lbl_rar.text = RARITY_TH.get(rarity, rarity)
	lbl_rar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_rar.modulate = col
	lbl_rar.add_theme_font_size_override("font_size", 10)
	vbox.add_child(lbl_rar)

	return panel

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------

func _on_close() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")
