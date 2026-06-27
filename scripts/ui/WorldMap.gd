extends Node2D
class_name WorldMap

# ---------------------------------------------------------------------------
# Node refs — unique names from world_map.tscn
# ---------------------------------------------------------------------------

@onready var _lbl_char_name:     Label       = %LblCharName
@onready var _lbl_divinity:      Label       = %LblDivinity
@onready var _hunger_bar:        ProgressBar = %HungerBar
@onready var _thirst_bar:        ProgressBar = %ThirstBar
@onready var _fatigue_bar:       ProgressBar = %FatigueBar
@onready var _lbl_world_energy:  Label       = %LblWorldEnergy
@onready var _lbl_battle_energy: Label       = %LblBattleEnergy
@onready var _location_bar:      Label       = %LocationBar
@onready var _lbl_time:          Label       = %LblTime
@onready var _survival_warning:  Label       = %SurvivalWarning
@onready var _decay_timer:       Timer       = $DecayTimer

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_populate_from_game_state()
	_connect_signals()
	_start_decay_timer()
	_wire_bottom_bar()


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
		push_warning("Craft: not yet implemented"))
	$HUD/BottomBar/BtnGacha.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/gacha_ui.tscn"))
	$HUD/BottomBar/BtnMenu.pressed.connect(_on_menu)

# ---------------------------------------------------------------------------
# Signal handlers
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
	_location_bar.text = tr("WM_LOCATION") % [GameState.current_band, GameState.current_floor]


func _on_time_changed(_is_night: bool) -> void:
	_lbl_time.text = TimeManager.get_time_label()


func _on_decay_tick() -> void:
	# Prototype client-side decay: 1 tick / 5 sec real time
	# Production: server drives decay via Supabase Edge Function
	GameState.set_survival(
		GameState.hunger  - 1.0,
		GameState.thirst  - 1.5,
		GameState.fatigue - 0.5,
	)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _survival_color(value: float) -> Color:
	if value < 15.0: return Color(1.0, 0.3, 0.3)   # red — critical
	if value < 35.0: return Color(1.0, 0.75, 0.2)  # orange — low
	return Color.WHITE


func _on_menu() -> void:
	# TODO: open pause-menu overlay instead of returning to main menu
	GameState.reset_session()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
