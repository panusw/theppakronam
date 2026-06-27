extends Control
class_name CharacterSelect

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _slots: Array[PanelContainer] = [
	$SlotContainer/Slot1,
	$SlotContainer/Slot2,
	$SlotContainer/Slot3,
]
@onready var _lbl_loading:        Label          = $LblLoading
@onready var _delete_modal:       PanelContainer = $DeleteModal
@onready var _lbl_delete_warning: Label          = $DeleteModal/VBox/LblDeleteWarning
@onready var _input_delete:       LineEdit       = $DeleteModal/VBox/InputDeleteConfirm
@onready var _btn_delete_confirm: Button         = $DeleteModal/VBox/HBox/BtnDeleteConfirm

var _characters: Array[Dictionary] = []
var _pending_delete: Dictionary    = {}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	$Header.text                                = tr("CS_HEADER")
	$DeleteModal/VBox/LblDeleteTitle.text       = tr("CS_DELETE_TITLE")
	_input_delete.placeholder_text              = tr("CS_DELETE_PLACEHOLDER")
	_btn_delete_confirm.text                    = tr("CS_BTN_CONFIRM_DELETE")
	$DeleteModal/VBox/HBox/BtnDeleteCancel.text = tr("CS_BTN_CANCEL")
	$BtnBack.text                               = tr("CS_BTN_BACK")
	_delete_modal.visible = false
	$DeleteModal/VBox/HBox/BtnDeleteCancel.pressed.connect(_close_delete_modal)
	_btn_delete_confirm.pressed.connect(_on_delete_confirmed)
	_input_delete.text_changed.connect(_on_delete_input_changed)
	$BtnBack.pressed.connect(_on_back)
	_load_characters()


func _load_characters() -> void:
	_lbl_loading.text    = tr("CS_LOADING")
	_lbl_loading.visible = true
	SupabaseClient.request_completed.connect(_on_chars_loaded, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_chars_failed, CONNECT_ONE_SHOT)
	# Query players table — RLS กรองเฉพาะ user ของตัวเองอัตโนมัติ
	SupabaseClient.db_get(
		"players",
		"?user_id=eq.%s&deleted_at=is.null&select=*&order=created_at.asc&limit=3" % GameState.player_id
	)

# ---------------------------------------------------------------------------
# Load handlers
# ---------------------------------------------------------------------------

func _on_chars_loaded(data: Variant) -> void:
	_lbl_loading.visible = false
	_characters = []
	if data is Array:
		for item in data:
			if item is Dictionary:
				_characters.append(item)
	_populate_slots()


func _on_chars_failed(_code: int, _msg: String) -> void:
	_lbl_loading.text = tr("CS_ERR_LOAD")

# ---------------------------------------------------------------------------
# Slot population
# ---------------------------------------------------------------------------

func _populate_slots() -> void:
	for i in 3:
		for child in _slots[i].get_children():
			child.queue_free()
		if i < _characters.size():
			_build_occupied_slot(_slots[i], _characters[i])
		else:
			_build_empty_slot(_slots[i])


func _build_occupied_slot(panel: PanelContainer, char_data: Dictionary) -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	vbox.alignment             = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var lbl_name := Label.new()
	lbl_name.text                 = char_data.get("name", "?")
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_name)

	var div: int   = char_data.get("divinity_level", 0)
	var band: int  = char_data.get("current_band",  1)
	var floor: int = char_data.get("current_floor", 1)

	var lbl_info := Label.new()
	lbl_info.text                 = tr("CS_DIVINITY_INFO") % [div, band, floor]
	lbl_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_info)

	_add_spacer(vbox, 16)

	var btn_play := Button.new()
	btn_play.text = tr("CS_BTN_PLAY")
	btn_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_play.pressed.connect(_select_character.bind(char_data))
	vbox.add_child(btn_play)

	var btn_del := Button.new()
	btn_del.text = tr("CS_BTN_DELETE")
	btn_del.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_del.pressed.connect(_request_delete.bind(char_data))
	vbox.add_child(btn_del)


func _build_empty_slot(panel: PanelContainer) -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	vbox.alignment             = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var lbl_plus := Label.new()
	lbl_plus.text                 = "+"
	lbl_plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_plus)

	var btn_new := Button.new()
	btn_new.text = tr("CS_BTN_NEW")
	btn_new.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_new.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/character_creator.tscn"))
	vbox.add_child(btn_new)


func _add_spacer(parent: VBoxContainer, height: int) -> void:
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, height)
	parent.add_child(sp)

# ---------------------------------------------------------------------------
# Character selection — โหลด GameState ทั้งหมดจากข้อมูลที่ดึงมาแล้ว
# ---------------------------------------------------------------------------

func _select_character(char_data: Dictionary) -> void:
	GameState.character_id        = char_data.get("id",             "")
	GameState.character_name      = char_data.get("name",           "")
	GameState.difficulty          = char_data.get("difficulty",     "normal")
	GameState.divinity_level      = char_data.get("divinity_level", 0)
	GameState.divinity_exp        = char_data.get("divinity_exp",   0)
	GameState.current_band        = char_data.get("current_band",   1)
	GameState.current_floor       = char_data.get("current_floor",  1)
	GameState.current_camp_id     = char_data.get("current_camp_id", "")
	GameState.world_energy        = char_data.get("world_energy",   100)
	GameState.battle_energy       = char_data.get("battle_energy",  10)
	GameState.gold                = char_data.get("gold",           0)
	GameState.gems                = char_data.get("gems",           0)
	GameState.gacha_pity          = char_data.get("gacha_pity",     0)
	GameState.hunger              = float(char_data.get("hunger",   100.0))
	GameState.thirst              = float(char_data.get("thirst",   100.0))
	GameState.fatigue             = float(char_data.get("fatigue",  100.0))
	var appearance = char_data.get("appearance", {})
	if appearance is Dictionary:
		GameState.pending_appearance = appearance
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

# ---------------------------------------------------------------------------
# Delete flow (soft delete — sets deleted_at, 2-step confirm)
# ---------------------------------------------------------------------------

func _request_delete(char_data: Dictionary) -> void:
	_pending_delete = char_data
	var char_name: String = char_data.get("name", "")
	_lbl_delete_warning.text = (tr("CS_DELETE_WARNING_LINE1") % char_name) \
		+ "\n" + tr("CS_DELETE_WARNING_LINE2")
	_input_delete.text           = ""
	_btn_delete_confirm.disabled = true
	_delete_modal.visible        = true


func _on_delete_input_changed(text: String) -> void:
	_btn_delete_confirm.disabled = (text != _pending_delete.get("name", ""))


func _on_delete_confirmed() -> void:
	_btn_delete_confirm.disabled = true
	SupabaseClient.request_completed.connect(_on_delete_done, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_delete_failed, CONNECT_ONE_SHOT)
	SupabaseClient.db_patch(
		"players",
		"?id=eq.%s" % _pending_delete.get("id", ""),
		{"deleted_at": Time.get_datetime_string_from_system(true)}
	)


func _on_delete_done(_data: Variant) -> void:
	_close_delete_modal()
	_load_characters()


func _on_delete_failed(code: int, _msg: String) -> void:
	_btn_delete_confirm.disabled = false
	_lbl_delete_warning.text     = tr("CS_ERR_DELETE") % code


func _close_delete_modal() -> void:
	_delete_modal.visible = false
	_pending_delete       = {}

# ---------------------------------------------------------------------------
# Back
# ---------------------------------------------------------------------------

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
