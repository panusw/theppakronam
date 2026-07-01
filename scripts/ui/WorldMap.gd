extends Node2D
class_name WorldMap

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _lbl_char_name:     Label              = %LblCharName
@onready var _lbl_divinity:      Label              = %LblDivinity
@onready var _hunger_bar:        ProgressBar        = %HungerBar
@onready var _thirst_bar:        ProgressBar        = %ThirstBar
@onready var _fatigue_bar:       ProgressBar        = %FatigueBar
@onready var _lbl_world_energy:  Label              = %LblWorldEnergy
@onready var _lbl_battle_energy: Label              = %LblBattleEnergy
@onready var _location_bar:      Label              = %LocationBar
@onready var _lbl_time:          Label              = %LblTime
@onready var _survival_warning:  Label              = %SurvivalWarning
@onready var _decay_timer:       Timer              = $DecayTimer
@onready var _camp_graph:        CampGraphRenderer  = $CampGraph
@onready var _camera:            Camera2D           = $Camera
@onready var _camp_info_panel:   PanelContainer     = %CampInfoPanel
@onready var _lbl_camp_name:     Label              = %LblCampName
@onready var _lbl_camp_type:     Label              = %LblCampType
@onready var _lbl_energy_cost:   Label              = %LblEnergyCost
@onready var _btn_travel:        Button             = %BtnTravel
@onready var _btn_close:         Button             = %BtnClose
@onready var _menu_overlay:      Control            = %MenuOverlay

# ---------------------------------------------------------------------------
# Camp data (loaded from Supabase or guest fallback)
# ---------------------------------------------------------------------------

var _camps:         Array[Dictionary] = []
var _connections:   Array[Dictionary] = []
var _visited_camps: Dictionary = {}   # camp_id → player_camp_state row
var _selected_camp: Dictionary = {}
var _band_id:       String = ""

const CAMP_TYPE_TH := {
	"spawn":        "จุดเริ่มต้น",
	"normal":       "แคมป์ธรรมดา",
	"elite":        "แคมป์อีลิท",
	"mini_boss":    "มินิบอส",
	"checkpoint":   "จุดหยุดพัก",
	"boss_gate":    "ประตูบอส",
	"boss":         "แคมป์บอส",
	"resource":     "แหล่งทรัพยากร",
	"mystery":      "แคมป์ปริศนา",
	"hunting_zone": "โซนล่าสัตว์",
	"hub":          "ศูนย์กลาง",
}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_populate_from_game_state()
	_connect_signals()
	_start_decay_timer()
	_wire_bottom_bar()
	_wire_info_panel()
	_load_band_camps()


func _exit_tree() -> void:
	if GameState.energy_changed.is_connected(_update_energy):
		GameState.energy_changed.disconnect(_update_energy)
	if GameState.survival_changed.is_connected(_update_survival):
		GameState.survival_changed.disconnect(_update_survival)
	if TimeManager.time_of_day_changed.is_connected(_on_time_changed):
		TimeManager.time_of_day_changed.disconnect(_on_time_changed)

# ---------------------------------------------------------------------------
# Init helpers
# ---------------------------------------------------------------------------

func _populate_from_game_state() -> void:
	_lbl_char_name.text = GameState.character_name if not GameState.character_name.is_empty() \
		else tr("WM_UNKNOWN_CHAR")
	_lbl_divinity.text  = GameState.get_divinity_title()
	_update_survival(GameState.hunger, GameState.thirst, GameState.fatigue)
	_update_energy(GameState.world_energy, GameState.battle_energy)
	_update_location()
	_lbl_time.text = TimeManager.get_time_label()


func _connect_signals() -> void:
	GameState.energy_changed.connect(_update_energy)
	GameState.survival_changed.connect(_update_survival)
	TimeManager.time_of_day_changed.connect(_on_time_changed)


func _start_decay_timer() -> void:
	_decay_timer.wait_time = 5.0
	_decay_timer.timeout.connect(_on_decay_tick)
	_decay_timer.start()


func _wire_bottom_bar() -> void:
	$HUD/BottomBar/BtnCombat.text    = tr("WM_BTN_COMBAT")
	$HUD/BottomBar/BtnInventory.text = tr("WM_BTN_INVENTORY")
	$HUD/BottomBar/BtnCraft.text     = tr("WM_BTN_CRAFT")
	$HUD/BottomBar/BtnGacha.text     = tr("WM_BTN_GACHA")
	$HUD/BottomBar/BtnMenu.text      = tr("WM_BTN_MENU")
	$HUD/BottomBar/BtnCombat.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/combat.tscn"))
	$HUD/BottomBar/BtnInventory.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/inventory.tscn"))
	$HUD/BottomBar/BtnCraft.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/skill_web.tscn"))
	$HUD/BottomBar/BtnGacha.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/gacha_ui.tscn"))
	$HUD/BottomBar/BtnMenu.pressed.connect(_on_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnCancel.pressed.connect(_on_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnTown.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/town.tscn"))
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnSettings.pressed.connect(_on_settings)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnMainMenu.pressed.connect(_on_go_main_menu)
	$HUD/MenuOverlay/MenuPanel/Margin/VBox/BtnQuit.pressed.connect(get_tree().quit)


func _wire_info_panel() -> void:
	_btn_travel.pressed.connect(_on_travel_pressed)
	_btn_close.pressed.connect(func(): _camp_info_panel.visible = false)
	_camp_graph.camp_clicked.connect(_on_camp_clicked)

# ---------------------------------------------------------------------------
# Camp graph loading — sequential Supabase fetch chain
# ---------------------------------------------------------------------------

func _load_band_camps() -> void:
	if GameState.is_guest:
		_build_guest_graph()
		return
	SupabaseClient.request_completed.connect(_on_band_id_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_map_load_error.bind("band"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("tower_bands",
		"?band_order=eq.%d&select=id" % GameState.current_band)


func _on_band_id_received(data: Variant) -> void:
	if data is Array and not (data as Array).is_empty():
		_band_id = (data as Array)[0].get("id", "")
	if _band_id.is_empty():
		push_error("WorldMap: band %d not found in DB" % GameState.current_band)
		return
	SupabaseClient.request_completed.connect(_on_floor_ids_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_map_load_error.bind("floors"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("tower_floors",
		"?band_id=eq.%s&select=id" % _band_id)


func _on_floor_ids_received(data: Variant) -> void:
	var floor_ids: Array[String] = []
	if data is Array:
		for row in data:
			if row is Dictionary:
				floor_ids.append(str(row["id"]))
	if floor_ids.is_empty():
		push_error("WorldMap: no floors found for band %s" % _band_id)
		return
	var in_clause := "(%s)" % ",".join(floor_ids)
	SupabaseClient.request_completed.connect(_on_camps_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_map_load_error.bind("camps"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("tower_camps",
		"?floor_id=in.%s&select=*&order=pos_y.asc,pos_x.asc" % in_clause)


func _on_camps_received(data: Variant) -> void:
	_camps.clear()
	if data is Array:
		for row in data:
			if row is Dictionary:
				_camps.append(row)
	if _camps.is_empty():
		_camp_graph.set_data([], [], {}, "")
		return
	var ids := "(%s)" % ",".join(_camps.map(func(c): return str(c["id"])))
	SupabaseClient.request_completed.connect(_on_connections_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_map_load_error.bind("connections"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("camp_connections",
		"?from_camp=in.%s&select=from_camp,to_camp" % ids)


func _on_connections_received(data: Variant) -> void:
	_connections.clear()
	if data is Array:
		for row in data:
			if row is Dictionary:
				_connections.append(row)
	var ids := "(%s)" % ",".join(_camps.map(func(c): return str(c["id"])))
	SupabaseClient.request_completed.connect(_on_camp_states_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_map_load_error.bind("states"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("player_camp_state",
		"?player_id=eq.%s&camp_id=in.%s&select=camp_id,is_visited,is_cleared" \
		% [GameState.character_id, ids])


func _on_camp_states_received(data: Variant) -> void:
	_visited_camps.clear()
	if data is Array:
		for row in data:
			if row is Dictionary and row.get("is_visited", false):
				_visited_camps[str(row["camp_id"])] = row
	_apply_graph()


func _apply_graph() -> void:
	# Default to spawn camp if no current camp set
	if GameState.current_camp_id.is_empty():
		for c in _camps:
			if c.get("camp_type") == "spawn":
				GameState.current_camp_id = str(c["id"])
				break
	_camp_graph.set_data(_camps, _connections, _visited_camps, GameState.current_camp_id)
	_pan_camera_to_camp(GameState.current_camp_id)
	_update_location()
	# Camp chain is done — now it's safe to fire stat refresh (won't compete for request_completed)
	if not GameState.is_guest:
		StatCalculator.request_refresh()


func _on_map_load_error(stage: String, _code: int, _msg: String) -> void:
	push_error("WorldMap: camp load failed at stage=%s code=%d" % [stage, _code])


# Guest mode: minimal hardcoded graph (no Supabase)
func _build_guest_graph() -> void:
	_camps = [
		{"id": "gs0", "camp_type": "spawn",  "name_th": "จุดเริ่มต้น", "name_en": "Start",
		 "pos_x": 0, "pos_y": 0, "energy_cost": 0},
		{"id": "gs1", "camp_type": "normal", "name_th": "ชายป่า",      "name_en": "Forest Edge",
		 "pos_x": 1, "pos_y": 0, "energy_cost": 4},
		{"id": "gs2", "camp_type": "normal", "name_th": "ลำธาร",       "name_en": "Stream",
		 "pos_x": 2, "pos_y": 0, "energy_cost": 4},
		{"id": "gs3", "camp_type": "hub",    "name_th": "หมู่บ้านศาล", "name_en": "Shrine Village",
		 "pos_x": 3, "pos_y": 0, "energy_cost": 2},
	]
	_connections = [
		{"from_camp": "gs0", "to_camp": "gs1"},
		{"from_camp": "gs1", "to_camp": "gs2"},
		{"from_camp": "gs2", "to_camp": "gs3"},
	]
	if GameState.current_camp_id.is_empty():
		GameState.current_camp_id = "gs0"
	_camp_graph.set_data(_camps, _connections, {}, GameState.current_camp_id)
	_update_location()
	StatCalculator.request_refresh()  # guest: uses local compute, no Supabase call

# ---------------------------------------------------------------------------
# Camera
# ---------------------------------------------------------------------------

func _pan_camera_to_camp(camp_id: String) -> void:
	if camp_id.is_empty():
		return
	var pos := _camp_graph.get_camp_position(camp_id)
	_camera.position = pos

# ---------------------------------------------------------------------------
# Camp info panel
# ---------------------------------------------------------------------------

func _on_camp_clicked(camp_id: String) -> void:
	_selected_camp = {}
	for c in _camps:
		if str(c["id"]) == camp_id:
			_selected_camp = c
			break
	if _selected_camp.is_empty():
		return

	var ctype:       String = _selected_camp.get("camp_type", "normal")
	var energy_cost: int    = int(_selected_camp.get("energy_cost", 4))

	_lbl_camp_name.text  = _selected_camp.get("name_th", "—")
	_lbl_camp_type.text  = CAMP_TYPE_TH.get(ctype, ctype)
	_lbl_energy_cost.text = tr("WM_CAMP_ENERGY") % energy_cost if energy_cost > 0 \
		else tr("WM_CAMP_ENERGY_FREE")

	var is_current := camp_id == GameState.current_camp_id
	_btn_travel.visible  = not is_current
	_btn_travel.disabled = is_current \
		or not _is_adjacent_to_current(camp_id) \
		or GameState.world_energy < energy_cost

	_camp_info_panel.visible = true


func _is_adjacent_to_current(camp_id: String) -> bool:
	for conn in _connections:
		var f := str(conn.get("from_camp", ""))
		var t := str(conn.get("to_camp", ""))
		if (f == GameState.current_camp_id and t == camp_id) or \
		   (t == GameState.current_camp_id and f == camp_id):
			return true
	return false


func _on_travel_pressed() -> void:
	if _selected_camp.is_empty():
		return
	var energy_cost: int = int(_selected_camp.get("energy_cost", 4))
	var camp_id:     String = str(_selected_camp["id"])

	GameState.set_world_energy(GameState.world_energy - energy_cost)
	GameState.current_camp_id   = camp_id
	GameState.current_camp_type = _selected_camp.get("camp_type", "normal")
	# Mark visited locally
	_visited_camps[camp_id] = {"camp_id": camp_id, "is_visited": true}
	_camp_info_panel.visible = false

	# Persist
	if not GameState.is_guest:
		_sync_camp_state(camp_id)
	else:
		GameState.save_guest()

	_camp_graph.set_data(_camps, _connections, _visited_camps, camp_id)
	_pan_camera_to_camp(camp_id)
	_update_location()


func _sync_camp_state(camp_id: String) -> void:
	SupabaseClient.db_upsert("player_camp_state", {
		"player_id":  GameState.character_id,
		"camp_id":    camp_id,
		"is_visited": true,
	})

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
		_survival_warning.text = (tr("WM_WARNING_PREFIX") % "  |  ".join(parts)) \
			+ "\n" + tr("WM_WARNING_SUFFIX")


func _update_energy(world: int, battle: int) -> void:
	_lbl_world_energy.text  = tr("WM_WORLD_ENERGY")  % world
	_lbl_battle_energy.text = tr("WM_BATTLE_ENERGY") % battle


func _update_location() -> void:
	var camp_name := ""
	for c in _camps:
		if str(c["id"]) == GameState.current_camp_id:
			camp_name = c.get("name_th", "")
			break
	if camp_name.is_empty():
		_location_bar.text = tr("WM_LOCATION") % [GameState.current_band, GameState.current_floor]
	else:
		_location_bar.text = "%s  —  %s" % [
			camp_name,
			tr("WM_LOCATION") % [GameState.current_band, GameState.current_floor],
		]


func _on_time_changed(_is_night: bool) -> void:
	_lbl_time.text = TimeManager.get_time_label()


func _on_decay_tick() -> void:
	GameState.set_survival(
		GameState.hunger  - 1.0,
		GameState.thirst  - 1.5,
		GameState.fatigue - 0.5,
	)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _survival_color(value: float) -> Color:
	if value < 15.0: return Color(1.0, 0.3, 0.3)
	if value < 35.0: return Color(1.0, 0.75, 0.2)
	return Color.WHITE


func _on_menu() -> void:
	_menu_overlay.visible = not _menu_overlay.visible


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_go_main_menu() -> void:
	if GameState.is_guest:
		GameState.save_guest()
	GameState.reset_session()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
