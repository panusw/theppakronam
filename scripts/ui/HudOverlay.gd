extends CanvasLayer
class_name HudOverlay
## Persistent HUD overlay — HP bar, energy, survival, status effects, toasts.
## Instantiate as child of any scene that needs the HUD.

@onready var _hp_bar:       ProgressBar = $TopBar/HpContainer/HPBar
@onready var _lbl_hp:       Label       = $TopBar/HpContainer/LblHP
@onready var _lbl_world_en: Label       = $TopBar/EnergyContainer/LblWorldEnergy
@onready var _lbl_battle_en:Label       = $TopBar/EnergyContainer/LblBattleEnergy
@onready var _lbl_hunger:   Label       = $TopBar/SurvivalContainer/LblHunger
@onready var _lbl_thirst:   Label       = $TopBar/SurvivalContainer/LblThirst
@onready var _lbl_fatigue:  Label       = $TopBar/SurvivalContainer/LblFatigue

func _ready() -> void:
	_refresh_all()
	GameState.energy_changed.connect(_on_energy)
	GameState.survival_changed.connect(_on_survival)
	GameState.stats_updated.connect(_on_stats_updated)


func _exit_tree() -> void:
	if GameState.energy_changed.is_connected(_on_energy):
		GameState.energy_changed.disconnect(_on_energy)
	if GameState.survival_changed.is_connected(_on_survival):
		GameState.survival_changed.disconnect(_on_survival)
	if GameState.stats_updated.is_connected(_on_stats_updated):
		GameState.stats_updated.disconnect(_on_stats_updated)


func _refresh_all() -> void:
	_on_energy(GameState.world_energy, GameState.battle_energy)
	_on_survival(GameState.hunger, GameState.thirst, GameState.fatigue)
	_on_stats_updated()


func _on_energy(world: int, battle: int) -> void:
	_lbl_world_en.text  = "⚡ %d" % world
	_lbl_battle_en.text = "🔋 %d" % battle


func _on_survival(hunger: float, thirst: float, fatigue: float) -> void:
	_lbl_hunger.text  = "🍖%d" % int(hunger)
	_lbl_thirst.text  = "💧%d" % int(thirst)
	_lbl_fatigue.text = "😴%d" % int(fatigue)
	_lbl_hunger.modulate  = _survival_color(hunger)
	_lbl_thirst.modulate  = _survival_color(thirst)
	_lbl_fatigue.modulate = _survival_color(fatigue)


func _on_stats_updated() -> void:
	var max_hp := maxi(1, int(GameState.stats.get("hp", 100)))
	_hp_bar.max_value = max_hp
	_hp_bar.value     = max_hp  # server-authoritative HP not tracked locally yet
	_lbl_hp.text      = "HP"


func _survival_color(value: float) -> Color:
	if value < 15.0: return Color(1.0, 0.3, 0.3)
	if value < 35.0: return Color(1.0, 0.75, 0.2)
	return Color.WHITE
