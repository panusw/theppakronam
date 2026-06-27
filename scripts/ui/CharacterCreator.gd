extends Control
class_name CharacterCreator

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

const HAIR_STYLES: Array[String] = [
	"",         # หัวล้าน — ซ่อน hair sprite
	"bowlhair", "curlyhair", "longhair",
	"mophair",  "shorthair", "spikeyhair",
]
const HAIR_LABELS: Array[String] = [
	"HAIR_BALD",
	"HAIR_BOWL", "HAIR_CURLY", "HAIR_LONG",
	"HAIR_MOP",  "HAIR_SHORT", "HAIR_SPIKY",
]
const IDLE_PATH   := "res://assets/sprites/character/human/IDLE/"
const IDLE_FRAMES := 9
const IDLE_FPS    := 8.0

# ---------------------------------------------------------------------------
# Node refs (matched to character_creator.tscn)
# ---------------------------------------------------------------------------

@onready var _body:        Sprite2D        = $PreviewPanel/PreviewViewport/CharacterSprite/Body
@onready var _tool:        Sprite2D        = $PreviewPanel/PreviewViewport/CharacterSprite/Tool
@onready var _hair:        Sprite2D        = $PreviewPanel/PreviewViewport/CharacterSprite/Hair
@onready var _options_box: VBoxContainer   = $OptionsScroll/OptionsVBox

# Created dynamically in _build_ui()
var _input_name:   LineEdit
var _btn_confirm:  Button
var _lbl_status:   Label

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _hair_idx:       int    = 0
var _skin_key:       String = "light"
var _outfit_key:     String = "navy"
var _outfit2_key:    String = "red"
var _hair_color_key: String = "brown"

var _anim_time: float = 0.0

var _body_mat: ShaderMaterial
var _tool_mat: ShaderMaterial
var _hair_mat: ShaderMaterial

# Button registries for highlight tracking
var _hair_style_btns:  Array[Button] = []
var _skin_btns:        Dictionary    = {}
var _hair_color_btns:  Dictionary    = {}
var _outfit_btns:      Dictionary    = {}
var _outfit2_btns:     Dictionary    = {}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_setup_materials()
	_build_ui()
	_update_preview()


func _process(delta: float) -> void:
	_anim_time += delta
	var frame := int(_anim_time * IDLE_FPS) % IDLE_FRAMES
	_body.frame = frame
	_tool.frame = frame
	if _hair.visible:
		_hair.frame = frame


func _setup_materials() -> void:
	_body_mat = CharacterColors.make_body_material()
	_tool_mat = CharacterColors.make_body_material()
	_hair_mat = CharacterColors.make_hair_material()

	_body.material = _body_mat
	_tool.material = _tool_mat
	_hair.material = _hair_mat

	_body.hframes = IDLE_FRAMES
	_body.frame   = 0
	_tool.hframes = IDLE_FRAMES
	_tool.frame   = 0
	_hair.hframes = IDLE_FRAMES
	_hair.frame   = 0

	var body_tex := load(IDLE_PATH + "base_idle_strip9.png") as Texture2D
	var tool_tex := load(IDLE_PATH + "tools_idle_strip9.png") as Texture2D
	if body_tex == null or tool_tex == null:
		push_error("CharacterCreator: ไม่พบ sprite ตัวละคร — ลอง Project > Tools > Reimport CSV / reimport assets ใน Godot editor")
	_body.texture = body_tex
	_tool.texture = tool_tex
	_hair.visible  = false  # default index 0 = ล้าน

	# โหลด mask texture สำหรับ body และ tools
	var body_mask := load(IDLE_PATH + "mask_base_idle_strip9.png") as Texture2D
	var tool_mask := load(IDLE_PATH + "mask_tools_idle_strip9.png") as Texture2D
	if body_mask == null or tool_mask == null:
		push_error("CharacterCreator: ไม่พบ mask texture — ต้อง reimport ใน Godot editor ก่อน (Project > Reimport All)")
	if body_mask != null:
		_body_mat.set_shader_parameter("mask_texture", body_mask)
	if tool_mask != null:
		_tool_mat.set_shader_parameter("mask_texture", tool_mask)

# ---------------------------------------------------------------------------
# UI construction (all option rows built at runtime)
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	# --- Name ---
	_add_label(tr("CC_NAME_LABEL"))
	_input_name = LineEdit.new()
	_input_name.placeholder_text = tr("CC_NAME_PLACEHOLDER")
	_input_name.max_length = 24
	_input_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_options_box.add_child(_input_name)
	_add_separator()

	# --- Hair style ---
	_add_label(tr("CC_HAIR_LABEL"))
	var style_row := HBoxContainer.new()
	style_row.add_theme_constant_override("separation", 8)
	for i in HAIR_STYLES.size():
		var btn := Button.new()
		btn.text = tr(HAIR_LABELS[i])
		btn.toggle_mode = true
		btn.button_pressed = (i == _hair_idx)
		btn.pressed.connect(_select_hair_style.bind(i))
		style_row.add_child(btn)
		_hair_style_btns.append(btn)
	_options_box.add_child(style_row)
	_add_separator()

	# --- Hair color ---
	_add_label(tr("CC_HAIR_COLOR_LABEL"))
	var hair_color_row := HBoxContainer.new()
	_hair_color_btns = _build_color_row(hair_color_row, CharacterColors.HAIR_PRESETS, _select_hair_color)
	_set_highlight(_hair_color_btns, _hair_color_key)
	_options_box.add_child(hair_color_row)
	_add_separator()

	# --- Skin tone ---
	_add_label(tr("CC_SKIN_LABEL"))
	var skin_row := HBoxContainer.new()
	_skin_btns = _build_color_row(skin_row, CharacterColors.SKIN_PRESETS, _select_skin)
	_set_highlight(_skin_btns, _skin_key)
	_options_box.add_child(skin_row)
	_add_separator()

	# --- Outfit outer (เอี้ยม) ---
	_add_label(tr("CC_OUTFIT_LABEL"))
	var outfit_row := HBoxContainer.new()
	_outfit_btns = _build_color_row(outfit_row, CharacterColors.OUTFIT_PRESETS, _select_outfit)
	_set_highlight(_outfit_btns, _outfit_key)
	_options_box.add_child(outfit_row)
	_add_separator()

	# --- Outfit inner (เสื้อ) ---
	_add_label(tr("CC_OUTFIT2_LABEL"))
	var outfit2_row := HBoxContainer.new()
	_outfit2_btns = _build_color_row(outfit2_row, CharacterColors.OUTFIT2_PRESETS, _select_outfit2)
	_set_highlight(_outfit2_btns, _outfit2_key)
	_options_box.add_child(outfit2_row)
	_add_separator()

	# --- Status label (loading / error messages) ---
	_lbl_status = Label.new()
	_lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_options_box.add_child(_lbl_status)

	# --- Action buttons ---
	_btn_confirm = Button.new()
	_btn_confirm.text = tr("CC_BTN_CONFIRM")
	_btn_confirm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_confirm.pressed.connect(_on_confirm)
	_options_box.add_child(_btn_confirm)

	var btn_back := Button.new()
	btn_back.text = tr("CC_BTN_BACK")
	btn_back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_back.pressed.connect(_on_back)
	_options_box.add_child(btn_back)


func _add_label(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	_options_box.add_child(lbl)


func _add_separator() -> void:
	var sep := HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 6)
	_options_box.add_child(sep)


## สร้าง color swatch buttons และเพิ่มใน container.
## คืน Dictionary {key → Button} สำหรับ highlight tracking.
func _build_color_row(
		container: HBoxContainer,
		presets:   Dictionary,
		callback:  Callable
) -> Dictionary:
	container.add_theme_constant_override("separation", 6)
	var btns: Dictionary = {}
	for key in presets.keys():
		var mid_color: Color = (presets[key] as Array)[1]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.tooltip_text = key
		btn.text = ""
		# StyleBoxFlat วาดสีบนตัว Button เอง — ไม่ต้องมี child node
		var sb := StyleBoxFlat.new()
		sb.bg_color = mid_color
		sb.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal",   sb)
		btn.add_theme_stylebox_override("hover",    _make_swatch_sb(mid_color.lightened(0.25)))
		btn.add_theme_stylebox_override("pressed",  _make_swatch_sb(mid_color.darkened(0.25)))
		btn.add_theme_stylebox_override("focus",    sb)
		btn.pressed.connect(callback.bind(key))
		container.add_child(btn)
		btns[key] = btn
	return btns


func _make_swatch_sb(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(4)
	return sb


## กำหนด selected button = สว่าง, ที่เหลือ = หรี่
func _set_highlight(btns: Dictionary, selected: String) -> void:
	for key in btns:
		(btns[key] as Button).modulate = Color.WHITE if key == selected else Color(0.55, 0.55, 0.55)

# ---------------------------------------------------------------------------
# Preview
# ---------------------------------------------------------------------------

func _update_preview() -> void:
	CharacterColors.apply_body_colors(_body_mat, _skin_key, _outfit_key, _outfit2_key)
	CharacterColors.apply_body_colors(_tool_mat, _skin_key, _outfit_key, _outfit2_key)
	CharacterColors.apply_hair_colors(_hair_mat, _hair_color_key, _outfit_key, _outfit2_key)

# ---------------------------------------------------------------------------
# Selection handlers
# ---------------------------------------------------------------------------

func _select_hair_style(idx: int) -> void:
	_hair_idx = idx
	for i in _hair_style_btns.size():
		_hair_style_btns[i].button_pressed = (i == idx)
	if HAIR_STYLES[idx].is_empty():
		_hair.visible = false
	else:
		var style := HAIR_STYLES[idx]
		var hair_tex  := load(IDLE_PATH + "%s_idle_strip9.png" % style) as Texture2D
		var hair_mask := load(IDLE_PATH + "mask_%s_idle_strip9.png" % style) as Texture2D
		if hair_tex != null:
			_hair.texture = hair_tex
			_hair.hframes = IDLE_FRAMES
			_hair.visible = true
		else:
			_hair.visible = false
			push_error("CharacterCreator: ไม่พบ hair sprite '%s'" % style)
		if hair_mask != null:
			_hair_mat.set_shader_parameter("mask_texture", hair_mask)
	_update_preview()


func _select_skin(key: String) -> void:
	_skin_key = key
	_set_highlight(_skin_btns, key)
	_update_preview()


func _select_hair_color(key: String) -> void:
	_hair_color_key = key
	_set_highlight(_hair_color_btns, key)
	_update_preview()


func _select_outfit(key: String) -> void:
	_outfit_key = key
	_set_highlight(_outfit_btns, key)
	_update_preview()


func _select_outfit2(key: String) -> void:
	_outfit2_key = key
	_set_highlight(_outfit2_btns, key)
	_update_preview()

# ---------------------------------------------------------------------------
# Confirm / Back
# ---------------------------------------------------------------------------

func _on_confirm() -> void:
	var char_name := _input_name.text.strip_edges()
	if char_name.is_empty():
		_input_name.placeholder_text = tr("CC_ERR_NO_NAME")
		return

	var appearance := {
		"hair_style": HAIR_STYLES[_hair_idx],
		"hair_color": _hair_color_key,
		"skin":       _skin_key,
		"outfit":     _outfit_key,
		"outfit2":    _outfit2_key,
	}
	GameState.character_name    = char_name
	GameState.pending_appearance = appearance

	if GameState.is_guest:
		GameState.save_guest()
		get_tree().change_scene_to_file("res://scenes/world_map.tscn")
		return

	_btn_confirm.disabled = true
	_set_status(tr("CC_STATUS_CREATING"))
	SupabaseClient.request_completed.connect(_on_create_done, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_create_failed, CONNECT_ONE_SHOT)
	SupabaseClient.call_rpc("create_character", {
		"p_player_id": GameState.player_id,
		"p_name":       char_name,
		"p_appearance": appearance,
	})


func _on_create_done(data: Variant) -> void:
	_btn_confirm.disabled = false
	var char_id := ""
	if data is Array and not data.is_empty() and data[0] is Dictionary:
		char_id = (data[0] as Dictionary).get("id", "")
	elif data is Dictionary:
		char_id = data.get("id", "")

	if char_id.is_empty():
		_set_status(tr("CC_ERR_CREATE_FAILED"))
		return

	GameState.character_id = char_id
	# ไปที่ character_select เสมอ เพื่อให้ผู้เล่นกด "เล่น" เลือกตัวละคร
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")


func _on_create_failed(code: int, message: String) -> void:
	_btn_confirm.disabled = false
	var parsed := JSON.new()
	if parsed.parse(message) == OK and parsed.get_data() is Dictionary:
		var d: Dictionary = parsed.get_data()
		message = d.get("message", d.get("msg", message))
	_set_status(tr("CC_ERR_REQUEST") % [code, message])


func _set_status(text: String) -> void:
	_lbl_status.text = text


func _on_back() -> void:
	if GameState.is_guest or not GameState.is_logged_in():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
