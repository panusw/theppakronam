extends Node2D
class_name Town

const WALK_SPEED  := 80.0
const IDLE_PATH   := "res://assets/sprites/character/human/IDLE/"
const WALK_PATH   := "res://assets/sprites/character/human/WALKING/"
const IDLE_FRAMES := 9
const WALK_FRAMES := 8
const ANIM_FPS    := 8.0

const _TILESET_PATH := "res://assets/tilesets/spr_tileset_sunnysideworld_16px.png"
const _FOREST_PATH  := "res://assets/tilesets/spr_tileset_sunnysideworld_forest_32px.png"

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _body:              Sprite2D    = $CharacterSprite/Body
@onready var _tool:              Sprite2D    = $CharacterSprite/Tool
@onready var _hair:              Sprite2D    = $CharacterSprite/Hair
@onready var _char_node:         Node2D      = $CharacterSprite
@onready var _decay_timer:       Timer       = $DecayTimer
@onready var _menu_overlay:      Control     = %MenuOverlay
@onready var _lbl_char_name:     Label       = %LblCharName
@onready var _lbl_divinity:      Label       = %LblDivinity
@onready var _hunger_bar:        ProgressBar = %HungerBar
@onready var _thirst_bar:        ProgressBar = %ThirstBar
@onready var _fatigue_bar:       ProgressBar = %FatigueBar
@onready var _lbl_world_energy:  Label       = %LblWorldEnergy
@onready var _lbl_battle_energy: Label       = %LblBattleEnergy
@onready var _survival_warning:  Label       = %SurvivalWarning

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _body_mat:      ShaderMaterial
var _tool_mat:      ShaderMaterial
var _anim_time:     float  = 0.0
var _is_walking:    bool   = false
var _cur_frames:    int    = IDLE_FRAMES
var _hair_style:    String = ""

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_setup_character()
	_setup_hud()
	_wire_buttons()
	GameState.energy_changed.connect(_update_energy)
	GameState.survival_changed.connect(_update_survival)
	_decay_timer.timeout.connect(_on_decay_tick)
	_decay_timer.start()


func _exit_tree() -> void:
	if GameState.energy_changed.is_connected(_update_energy):
		GameState.energy_changed.disconnect(_update_energy)
	if GameState.survival_changed.is_connected(_update_survival):
		GameState.survival_changed.disconnect(_update_survival)

# ---------------------------------------------------------------------------
# Character sprite setup
# ---------------------------------------------------------------------------

func _setup_character() -> void:
	var ap: Dictionary = GameState.pending_appearance
	var skin_key    := ap.get("skin",       "light") as String
	var outfit_key  := ap.get("outfit",     "navy")  as String
	var outfit2_key := ap.get("outfit2",    "red")   as String
	_hair_style      = ap.get("hair_style", "")      as String

	_body_mat = CharacterColors.make_body_material()
	_tool_mat = CharacterColors.make_body_material()
	_body.material = _body_mat
	_tool.material = _tool_mat

	CharacterColors.apply_body_colors(_body_mat, skin_key, outfit_key, outfit2_key)
	CharacterColors.apply_body_colors(_tool_mat, skin_key, outfit_key, outfit2_key)

	_load_anim(false)   # start in IDLE


func _load_anim(walking: bool) -> void:
	_anim_time  = 0.0
	_cur_frames = WALK_FRAMES if walking else IDLE_FRAMES
	var base_dir  := WALK_PATH if walking else IDLE_PATH
	var suffix    := "_walk_strip8.png" if walking else "_idle_strip9.png"

	var body_tex  := load(base_dir + "base" + suffix) as Texture2D
	var tool_tex  := load(base_dir + "tools" + suffix) as Texture2D
	var body_mask := load(base_dir + "mask_base" + suffix) as Texture2D
	var tool_mask := load(base_dir + "mask_tools" + suffix) as Texture2D

	_body.texture = body_tex
	_tool.texture = tool_tex
	_body.hframes = _cur_frames
	_tool.hframes = _cur_frames
	if body_mask: _body_mat.set_shader_parameter("mask_texture", body_mask)
	if tool_mask: _tool_mat.set_shader_parameter("mask_texture", tool_mask)

	if _hair_style.is_empty():
		_hair.visible = false
	else:
		var hair_tex := load(base_dir + _hair_style + suffix) as Texture2D
		if hair_tex:
			_hair.texture = hair_tex
			_hair.hframes = _cur_frames
			_hair.visible = true

# ---------------------------------------------------------------------------
# HUD init
# ---------------------------------------------------------------------------

func _setup_hud() -> void:
	_lbl_char_name.text = GameState.character_name if not GameState.character_name.is_empty() \
		else tr("WM_UNKNOWN_CHAR")
	_lbl_divinity.text  = GameState.get_divinity_title()
	_update_survival(GameState.hunger, GameState.thirst, GameState.fatigue)
	_update_energy(GameState.world_energy, GameState.battle_energy)
	$HUD/BottomBar/BtnMap.text       = tr("TN_BTN_MAP")
	$HUD/BottomBar/BtnInventory.text = tr("TN_BTN_INVENTORY")
	$HUD/BottomBar/BtnMenu.text      = tr("TN_BTN_MENU")


func _wire_buttons() -> void:
	$HUD/BottomBar/BtnMap.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/world_map.tscn"))
	$HUD/BottomBar/BtnInventory.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/inventory.tscn"))
	$HUD/BottomBar/BtnMenu.pressed.connect(_toggle_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnCancel.pressed.connect(_toggle_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnSettings.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/settings.tscn"))
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnMainMenu.pressed.connect(_on_go_main_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnQuit.pressed.connect(get_tree().quit)


func _toggle_menu() -> void:
	_menu_overlay.visible = not _menu_overlay.visible


func _on_go_main_menu() -> void:
	if GameState.is_guest:
		GameState.save_guest()
	GameState.reset_session()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ---------------------------------------------------------------------------
# Town map builder
# ---------------------------------------------------------------------------

func _build_map() -> void:
	var map := Node2D.new()
	map.name = "TownMap"
	add_child(map)
	move_child(map, 1)   # after Background (z=0), before CharacterSprite

	var ts  := load(_TILESET_PATH) as Texture2D
	var fts := load(_FOREST_PATH)  as Texture2D

	# Paths (sandy-brown ColorRects)
	_add_crect(map, Color(0.72, 0.58, 0.40), Rect2(-400, -10, 800, 20))   # horizontal
	_add_crect(map, Color(0.72, 0.58, 0.40), Rect2(-10, -80, 20, 480))    # vertical (south exit)

	# Town plaza — slightly lighter stone color
	_add_crect(map, Color(0.84, 0.75, 0.57), Rect2(-80, -64, 160, 128))

	# Water pond (SE corner) — border first, water on top
	_add_crect(map, Color(0.18, 0.46, 0.76), Rect2(196, 66, 112, 88))
	_add_crect(map, Color(0.25, 0.60, 0.95), Rect2(200, 70, 104, 80))

	# Houses — sunnyside 16px region(0, 80, 128, 112)
	_add_atl_sprite(map, ts, Rect2(0, 80, 128, 112), Vector2(-265, -230))  # NW
	_add_atl_sprite(map, ts, Rect2(0, 80, 128, 112), Vector2( 110, -230))  # NE
	_add_atl_sprite(map, ts, Rect2(0, 80, 128, 112), Vector2(-265,  80))   # SW

	# Trees — forest tileset, top-left tree sprite region(0, 0, 64, 64)
	var tree_px := [
		Vector2(-400, -290), Vector2(-280, -290), Vector2(-140, -295),
		Vector2(  40, -295), Vector2( 190, -290), Vector2( 340, -290),
		Vector2(-420, -110), Vector2( 420, -110),
		Vector2(-420,  100), Vector2( 420,  100),
		Vector2(-400,  270), Vector2(-180,  270),
		Vector2(  80,  270), Vector2( 340,  270),
	]
	for p in tree_px:
		_add_atl_sprite(map, fts, Rect2(0, 0, 64, 64), p)


func _add_crect(parent: Node2D, color: Color, rect: Rect2) -> void:
	var poly := Polygon2D.new()
	poly.color   = color
	poly.polygon = PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])
	parent.add_child(poly)


func _add_atl_sprite(parent: Node2D, tex: Texture2D, region: Rect2, pos: Vector2) -> void:
	var a := AtlasTexture.new()
	a.atlas  = tex
	a.region = region
	var s := Sprite2D.new()
	s.texture  = a
	s.centered = false
	s.position = pos
	parent.add_child(s)


# ---------------------------------------------------------------------------
# Movement + animation
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	var dx := int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) \
	        - int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	var dy := int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) \
	        - int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	var dir := Vector2(dx, dy).normalized()

	if dir != Vector2.ZERO:
		_char_node.position += dir * WALK_SPEED * delta
		if dir.x != 0.0:
			_body.flip_h = dir.x < 0.0
			_tool.flip_h = dir.x < 0.0
			_hair.flip_h = dir.x < 0.0
		if not _is_walking:
			_is_walking = true
			_load_anim(true)
	else:
		if _is_walking:
			_is_walking = false
			_load_anim(false)

	_anim_time += delta
	var frame := int(_anim_time * ANIM_FPS) % _cur_frames
	_body.frame = frame
	_tool.frame = frame
	if _hair.visible:
		_hair.frame = frame

# ---------------------------------------------------------------------------
# HUD signal handlers
# ---------------------------------------------------------------------------

func _update_survival(hunger: float, thirst: float, fatigue: float) -> void:
	_hunger_bar.value  = hunger
	_thirst_bar.value  = thirst
	_fatigue_bar.value = fatigue
	_hunger_bar.modulate  = _survival_color(hunger)
	_thirst_bar.modulate  = _survival_color(thirst)
	_fatigue_bar.modulate = _survival_color(fatigue)
	var critical := hunger < 15.0 or thirst < 15.0 or fatigue < 15.0
	_survival_warning.visible = critical
	if critical:
		var parts: Array[String] = []
		if hunger  < 15.0: parts.append(tr("WM_SURVIVAL_HUNGRY"))
		if thirst  < 15.0: parts.append(tr("WM_SURVIVAL_THIRSTY"))
		if fatigue < 15.0: parts.append(tr("WM_SURVIVAL_TIRED"))
		_survival_warning.text = tr("WM_WARNING_PREFIX") % "  |  ".join(parts)


func _update_energy(world: int, battle: int) -> void:
	_lbl_world_energy.text  = tr("WM_WORLD_ENERGY")  % world
	_lbl_battle_energy.text = tr("WM_BATTLE_ENERGY") % battle


func _on_decay_tick() -> void:
	GameState.set_survival(
		GameState.hunger  - 1.0,
		GameState.thirst  - 1.5,
		GameState.fatigue - 0.5,
	)


func _survival_color(value: float) -> Color:
	if value < 15.0: return Color(1.0, 0.3, 0.3)
	if value < 35.0: return Color(1.0, 0.75, 0.2)
	return Color.WHITE
