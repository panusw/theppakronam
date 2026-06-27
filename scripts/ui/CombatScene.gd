extends Node
class_name CombatScene
## Combat scene controller.
## Loads enemy template, creates ATBCombat, wires UI.

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _player_hp_bar:   ProgressBar   = $UI/TopBar/PlayerHP
@onready var _player_atb_bar:  ProgressBar   = $UI/TopBar/PlayerATB
@onready var _lbl_energy:      Label         = $UI/TopBar/EnergyLabel
@onready var _lbl_enemy_name:  Label         = $UI/EnemyBar/LblEnemyName
@onready var _enemy_hp_bar:    ProgressBar   = $UI/EnemyBar/EnemyHPBar
@onready var _enemy_atb_bar:   ProgressBar   = $UI/EnemyBar/EnemyATBBar
@onready var _combat_log:      RichTextLabel = $UI/CombatLog
@onready var _action_panel:    PanelContainer = $UI/ActionPanel
@onready var _btn_attack:      Button        = $UI/ActionPanel/ActionButtons/BtnAttack
@onready var _btn_skill:       Button        = $UI/ActionPanel/ActionButtons/BtnSkill
@onready var _btn_item:        Button        = $UI/ActionPanel/ActionButtons/BtnItem
@onready var _btn_flee:        Button        = $UI/ActionPanel/ActionButtons/BtnFlee
@onready var _btn_capture:     Button        = $UI/ActionPanel/ActionButtons/BtnCapture
@onready var _dice_panel:      PanelContainer = $UI/DicePanel
@onready var _lbl_dice_title:  Label         = $UI/DicePanel/Margin/VBox/LblDiceTitle
@onready var _lbl_dice_value:  Label         = $UI/DicePanel/Margin/VBox/LblDiceValue
@onready var _lbl_dice_effect: Label         = $UI/DicePanel/Margin/VBox/LblDiceEffect
@onready var _btn_dice_roll:   Button        = $UI/DicePanel/Margin/VBox/BtnDiceRoll
@onready var _btn_dice_confirm:Button        = $UI/DicePanel/Margin/VBox/BtnDiceConfirm
@onready var _result_panel:    PanelContainer = $UI/ResultPanel
@onready var _lbl_result:      Label         = $UI/ResultPanel/Margin/VBox/LblResult
@onready var _lbl_rewards:     Label         = $UI/ResultPanel/Margin/VBox/LblRewards
@onready var _btn_back:        Button        = $UI/ResultPanel/Margin/VBox/BtnBackToMap

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _combat:          ATBCombat
var _enemy:           CombatEntity
var _dice_context:    String = ""   # "flee" or "capture"
var _dice_roll_value: int    = 0

# Hardcoded fallback enemy templates by camp_type (for guest / offline / missing DB data)
const FALLBACK_ENEMIES := {
	"normal":       {"name_th":"หมูป่า",     "name_en":"Wild Boar",
					 "hp":45,"atk":7,"defense":2,"spd":8,"energy":6,"energy_regen":1,
					 "crit_rate":0.05,"crit_dmg":0.50,"ai_archetype":"berserker",
					 "durability_damage_mult":1.0,"is_capturable":true,"capture_base_rate":0.25},
	"elite":        {"name_th":"ทหารเก่า",   "name_en":"Old Guard",
					 "hp":90,"atk":14,"defense":8,"spd":7,"energy":10,"energy_regen":1,
					 "crit_rate":0.07,"crit_dmg":0.55,"ai_archetype":"tactician",
					 "durability_damage_mult":1.5,"is_capturable":true,"capture_base_rate":0.15},
	"mini_boss":    {"name_th":"นาคราช",     "name_en":"Naga King",
					 "hp":200,"atk":18,"defense":10,"spd":7,"energy":15,"energy_regen":2,
					 "crit_rate":0.10,"crit_dmg":0.60,"ai_archetype":"tactician",
					 "durability_damage_mult":2.0,"is_capturable":false,"capture_base_rate":0.0},
	"boss":         {"name_th":"มหายักษ์ทรนง","name_en":"Mahayak Thoranong",
					 "hp":500,"atk":25,"defense":15,"spd":5,"energy":20,"energy_regen":3,
					 "crit_rate":0.08,"crit_dmg":0.60,"ai_archetype":"tactician",
					 "durability_damage_mult":3.0,"is_capturable":false,"capture_base_rate":0.0},
	"resource":     {"name_th":"ตะขาบยักษ์","name_en":"Giant Centipede",
					 "hp":55,"atk":8,"defense":3,"spd":7,"energy":6,"energy_regen":1,
					 "crit_rate":0.06,"crit_dmg":0.50,"ai_archetype":"berserker",
					 "durability_damage_mult":1.0,"is_capturable":true,"capture_base_rate":0.35},
	"mystery":      {"name_th":"ผีรักษาการณ์","name_en":"Ghost Sentinel",
					 "hp":70,"atk":16,"defense":4,"spd":10,"energy":8,"energy_regen":1,
					 "crit_rate":0.12,"crit_dmg":0.60,"ai_archetype":"trickster",
					 "durability_damage_mult":1.5,"is_capturable":true,"capture_base_rate":0.10},
	"hunting_zone": {"name_th":"หมาป่า",     "name_en":"Forest Wolf",
					 "hp":50,"atk":10,"defense":2,"spd":10,"energy":6,"energy_regen":1,
					 "crit_rate":0.08,"crit_dmg":0.50,"ai_archetype":"berserker",
					 "durability_damage_mult":1.0,"is_capturable":true,"capture_base_rate":0.35},
}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_action_panel.visible = false
	_dice_panel.visible   = false
	_result_panel.visible = false
	_btn_capture.visible  = false

	_combat_log.text = ""

	_wire_buttons()
	_load_enemy()


func _wire_buttons() -> void:
	_btn_attack.pressed.connect(func(): _combat.execute_attack())
	_btn_flee.pressed.connect(_on_btn_flee)
	_btn_capture.pressed.connect(_on_btn_capture)
	_btn_skill.pressed.connect(func(): push_warning("Skill: not yet implemented"))
	_btn_item.pressed.connect(func(): push_warning("Item: not yet implemented"))
	_btn_dice_roll.pressed.connect(_on_dice_roll)
	_btn_dice_confirm.pressed.connect(_on_dice_confirm)
	_btn_back.pressed.connect(_on_back_to_map)

# ---------------------------------------------------------------------------
# Enemy loading
# ---------------------------------------------------------------------------

func _load_enemy() -> void:
	if GameState.is_guest:
		_start_combat_with_fallback()
		return
	# Load random enemy matching camp type from Supabase
	var camp_type := GameState.current_camp_type
	SupabaseClient.request_completed.connect(_on_enemy_loaded, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_enemy_load_failed, CONNECT_ONE_SHOT)
	SupabaseClient.db_get("enemy_templates",
		"?band_id=eq.%d&camp_types=cs.{\"%s\"}&select=*&limit=20" \
		% [GameState.current_band, camp_type])


func _on_enemy_loaded(data: Variant) -> void:
	if data is Array and not (data as Array).is_empty():
		var pool: Array = data as Array
		var tmpl: Dictionary = pool[randi() % pool.size()]
		_enemy = CombatEntity.from_template(tmpl)
		_start_combat()
	else:
		_start_combat_with_fallback()


func _on_enemy_load_failed(_code: int, _msg: String) -> void:
	_start_combat_with_fallback()


func _start_combat_with_fallback() -> void:
	var camp_type := GameState.current_camp_type
	var tmpl := FALLBACK_ENEMIES.get(camp_type,
		FALLBACK_ENEMIES["normal"]) as Dictionary
	_enemy = CombatEntity.from_template(tmpl)
	_start_combat()

# ---------------------------------------------------------------------------
# Combat init
# ---------------------------------------------------------------------------

func _start_combat() -> void:
	var player := CombatEntity.from_game_state()

	_combat = ATBCombat.new()
	_combat.player = player
	_combat.enemies = [_enemy]
	add_child(_combat)

	_combat.player_turn_ready.connect(_on_player_turn_ready)
	_combat.action_resolved.connect(_on_action_resolved)
	_combat.entity_updated.connect(_on_entity_updated)
	_combat.combat_ended.connect(_on_combat_ended)

	# Init bars
	_player_hp_bar.max_value  = player.max_hp
	_player_hp_bar.value      = player.current_hp
	_player_atb_bar.max_value = 100.0
	_player_atb_bar.value     = 0.0
	_enemy_hp_bar.max_value   = _enemy.max_hp
	_enemy_hp_bar.value       = _enemy.current_hp
	_enemy_atb_bar.max_value  = 100.0
	_enemy_atb_bar.value      = 0.0
	_lbl_enemy_name.text      = _enemy.name_th
	_lbl_energy.text          = "🔋 %d" % player.current_energy

	_log("[color=gold]⚔ เริ่มการต่อสู้![/color]")
	_log("[color=white]%s ปรากฏตัว![/color]" % _enemy.name_th)

# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_player_turn_ready() -> void:
	var player := _combat.player
	_btn_attack.disabled  = false
	_btn_skill.disabled   = true   # TODO
	_btn_item.disabled    = true   # TODO
	_btn_flee.disabled    = player.current_energy < 2
	_btn_capture.visible  = _enemy.show_capture_btn()
	_btn_capture.disabled = player.current_energy < 5
	_action_panel.visible = true


func _on_action_resolved(_actor: String, data: Dictionary) -> void:
	_action_panel.visible = false
	var action_type: String = data.get("type", "")
	match action_type:
		"attack", "heavy_attack":
			if data.get("miss", false):
				_log("[color=gray]✗ %s โจมตีพลาด![/color]" % _actor)
			else:
				var dmg: int  = data.get("damage", 0)
				var crit: bool = data.get("is_crit", false)
				var target: String = data.get("target_name", "")
				if crit:
					_log("[color=orange]💥 CRIT! %s → %s -%d HP![/color]" % [_actor, target, dmg])
				else:
					_log("[color=white]⚔ %s → %s -%d HP[/color]" % [_actor, target, dmg])
		"flee_attempt":
			if data.get("success", false):
				_log("[color=cyan]🏃 หนีสำเร็จ![/color]")
			else:
				_log("[color=red]🏃 หนีไม่สำเร็จ![/color]")
		"capture_attempt":
			if data.get("success", false):
				_log("[color=green]🪤 จับ %s สำเร็จ![/color]" % data.get("target", ""))
			elif data.get("enemy_fled", false):
				_log("[color=red]💥 กับดักระเบิด! %s หนีไป![/color]" % data.get("target", ""))
			else:
				_log("[color=red]🪤 จับไม่สำเร็จ[/color]")
		"item":
			_log("[color=cyan]🧪 ใช้ potion — ฟื้นฟู %d HP/turn × %d turns[/color]" \
				% [data.get("hp_per_turn", 0), data.get("turns", 0)])


func _on_entity_updated(entity: CombatEntity) -> void:
	if entity == _combat.player:
		_player_hp_bar.value  = entity.current_hp
		_player_atb_bar.value = entity.atb
		_lbl_energy.text      = "🔋 %d / %d" % [entity.current_energy, entity.max_energy]
		_player_hp_bar.modulate = _hp_color(entity.hp_pct())
	elif entity == _enemy:
		_enemy_hp_bar.value   = entity.current_hp
		_enemy_atb_bar.value  = entity.atb
		_enemy_hp_bar.modulate = _hp_color(entity.hp_pct())
		_btn_capture.visible  = entity.show_capture_btn()


func _on_combat_ended(result: String, rewards: Dictionary) -> void:
	_action_panel.visible = false
	_dice_panel.visible   = false

	match result:
		"win":
			if rewards.get("captured", false):
				_lbl_result.text = "🪤 จับได้!\n%s" % rewards.get("captured_name", "")
			else:
				_lbl_result.text = "✨ ชนะ!"
			var exp: int = rewards.get("divinity_exp", 0)
			_lbl_rewards.text = "Divinity EXP +%d" % exp if exp > 0 else ""
		"lose":
			_lbl_result.text  = "💀 แพ้..."
			_lbl_rewards.text = _death_penalty_text()
			_apply_death_penalty()
		"fled":
			_lbl_result.text  = "🏃 หนีได้!"
			_lbl_rewards.text = ""
		_:
			_lbl_result.text  = result
			_lbl_rewards.text = ""

	_result_panel.visible = true

# ---------------------------------------------------------------------------
# Button handlers
# ---------------------------------------------------------------------------

func _on_btn_flee() -> void:
	_open_dice_panel("flee")


func _on_btn_capture() -> void:
	_open_dice_panel("capture")


# ---------------------------------------------------------------------------
# Dice panel
# ---------------------------------------------------------------------------

func _open_dice_panel(context: String) -> void:
	_dice_context    = context
	_dice_roll_value = 0
	_action_panel.visible  = false
	_lbl_dice_title.text  = "ทอยเต๋า%s" % ("หนี" if context == "flee" else "จับ")
	_lbl_dice_value.text  = "—"
	_lbl_dice_effect.text = ""
	_btn_dice_roll.disabled    = false
	_btn_dice_confirm.visible  = false
	_dice_panel.visible = true


func _on_dice_roll() -> void:
	_dice_roll_value = MinigameDice.roll()
	_lbl_dice_value.text = str(_dice_roll_value)
	_lbl_dice_value.add_theme_color_override("font_color", _dice_color(_dice_roll_value))

	var grade  := MinigameDice.get_grade(_dice_roll_value)
	var flavour: String
	if _dice_context == "flee":
		flavour = MinigameDice.get_flee_flavour(_dice_roll_value)
		var mod := MinigameDice.get_flee_modifier(_dice_roll_value)
		_lbl_dice_effect.text = "%s\n%s  (%s%.0f%%)" % [
			grade, flavour,
			"+" if mod >= 0 else "", mod * 100.0
		]
	else:
		flavour = MinigameDice.get_capture_flavour(_dice_roll_value)
		var mod := MinigameDice.get_capture_modifier(_dice_roll_value)
		_lbl_dice_effect.text = "%s\n%s  (%s%.0f%%)" % [
			grade, flavour,
			"+" if mod >= 0 else "", mod * 100.0
		]

	_btn_dice_roll.disabled   = true
	_btn_dice_confirm.visible = true


func _on_dice_confirm() -> void:
	_dice_panel.visible = false
	if _dice_context == "flee":
		_combat.execute_flee(_dice_roll_value)
	else:
		# For Phase 1: assume Common Trap if no inventory check
		_combat.execute_capture("common", _dice_roll_value)

# ---------------------------------------------------------------------------
# End-game helpers
# ---------------------------------------------------------------------------

func _death_penalty_text() -> String:
	match GameState.difficulty:
		"hard":      return "สูญเสีย gold 10%"
		"ascendant": return "สูญเสีย gold 20% + crafting materials"
		"eternal":   return "⚠ ตัวละครถูกล็อก!"
		_:           return "กลับสู่ checkpoint"


func _apply_death_penalty() -> void:
	match GameState.difficulty:
		"hard":
			var loss := int(float(GameState.gold) * 0.10)
			GameState.gold = maxi(0, GameState.gold - loss)
		"ascendant":
			var loss := int(float(GameState.gold) * 0.20)
			GameState.gold = maxi(0, GameState.gold - loss)
	# Restore 50% HP at respawn
	if GameState.stats.has("hp"):
		GameState.stats["hp"] = maxi(1, int(float(GameState.stats.get("hp", 100)) * 0.50))


func _on_back_to_map() -> void:
	# Log combat session to Supabase (fire and forget)
	if not GameState.is_guest and _combat != null:
		SupabaseClient.call_rpc("log_combat_session", {
			"p_player_id":         GameState.character_id,
			"p_camp_id":           GameState.current_camp_id,
			"p_enemy_template_id": _enemy.template_id if _enemy else null,
			"p_enemy_name":        _enemy.name_en    if _enemy else "unknown",
			"p_status":            _combat_result_status(),
			"p_player_hp_start":   _combat.player.max_hp,
			"p_player_hp_end":     _combat.player.current_hp,
			"p_player_en_start":   _combat.player.max_energy,
			"p_player_en_end":     _combat.player.current_energy,
			"p_enemy_hp_start":    _enemy.max_hp if _enemy else 0,
			"p_enemy_hp_end":      _enemy.current_hp if _enemy else 0,
			"p_turns_taken":       _combat.turn_count,
		})
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")


func _combat_result_status() -> String:
	if _combat == null:
		return "unknown"
	match _combat.state:
		ATBCombat.State.WIN:  return "win"
		ATBCombat.State.LOSE: return "lose"
		ATBCombat.State.FLED: return "fled"
		_:                    return "unknown"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _log(bbcode: String) -> void:
	_combat_log.append_text(bbcode + "\n")


func _hp_color(pct: float) -> Color:
	if pct < 0.25: return Color("#ff4444")
	if pct < 0.50: return Color("#ffaa00")
	return Color.WHITE


func _dice_color(roll: int) -> Color:
	if roll == 1:          return Color("#ff4444")
	elif roll <= 8:        return Color("#ffaa00")
	elif roll <= 12:       return Color.WHITE
	elif roll <= 18:       return Color("#44ff88")
	else:                  return Color("#ffdd00")
