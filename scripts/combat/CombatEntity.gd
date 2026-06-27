extends RefCounted
class_name CombatEntity
## In-memory representation of one unit in ATB combat.
## Shared by player and all enemies — use is_player to distinguish.

var name_th:        String  = "?"
var name_en:        String  = "?"
var is_player:      bool    = false

# HP / Energy
var max_hp:         int     = 100
var current_hp:     int     = 100
var max_energy:     int     = 10
var current_energy: int     = 10

# ATB (0–100)
var atb:            float   = 0.0

# Base stats
var atk:            int     = 10
var defense:        int     = 5
var spd:            int     = 8
var crit_rate:      float   = 0.05
var crit_dmg:       float   = 0.50
var all_dmg:        float   = 0.0
var hp_regen:       int     = 0
var energy_regen:   int     = 1

# Active Heals Over Time: Array[{hp_per_turn: int, turns_left: int}]
var active_hots: Array = []

# Enemy-only fields
var archetype:          String  = "berserker"
var durability_mult:    float   = 1.0
var is_capturable:      bool    = true
var capture_base_rate:  float   = 0.25
var template_id:        String  = ""  # UUID of enemy_template row

# Boss phase tracking (enemies only)
var current_phase:  int = 0
var phase_triggered: Array[bool] = []


# ---------------------------------------------------------------------------
# State queries
# ---------------------------------------------------------------------------

func is_alive() -> bool:
	return current_hp > 0


func is_exhausted() -> bool:
	return current_energy <= 0


func hp_pct() -> float:
	return float(current_hp) / float(max_hp) if max_hp > 0 else 0.0


func atb_pct() -> float:
	return atb / 100.0


## ATK miss modifier when player is exhausted
func miss_modifier() -> float:
	return 0.15 if is_exhausted() else 0.0


## Incoming damage multiplier when exhausted
func dmg_recv_modifier() -> float:
	return 1.10 if is_exhausted() else 1.0


## Show capture button when enemy HP < 10%
func show_capture_btn() -> bool:
	return (not is_player) and is_capturable and hp_pct() < 0.10


# ---------------------------------------------------------------------------
# Per-turn housekeeping (called before acting each turn)
# ---------------------------------------------------------------------------

func tick_regen() -> void:
	current_energy = mini(max_energy, current_energy + energy_regen)
	current_hp     = mini(max_hp,     current_hp     + hp_regen)
	# Process HOTs
	var done: Array = []
	for hot in active_hots:
		current_hp = mini(max_hp, current_hp + int(hot.get("hp_per_turn", 0)))
		hot["turns_left"] = int(hot["turns_left"]) - 1
		if int(hot["turns_left"]) <= 0:
			done.append(hot)
	for h in done:
		active_hots.erase(h)


# ---------------------------------------------------------------------------
# Damage / healing / energy
# ---------------------------------------------------------------------------

## Apply incoming damage. Returns actual HP lost.
func take_damage(raw_atk: int, attacker_all_dmg: float = 0.0) -> int:
	var reduced := maxi(1, raw_atk - defense)
	var total   := int(float(reduced) * (1.0 + attacker_all_dmg) * dmg_recv_modifier())
	current_hp  = maxi(0, current_hp - total)
	return total


## Heal HP (capped at max). Returns actual HP gained.
func heal(amount: int) -> int:
	var prev  := current_hp
	current_hp = mini(max_hp, current_hp + amount)
	return current_hp - prev


## Add a HOT entry (Heal Over Time from item use).
func add_hot(hp_per_turn: int, turns: int) -> void:
	active_hots.append({"hp_per_turn": hp_per_turn, "turns_left": turns})


## Spend energy (clamp at 0).
func spend_energy(amount: int) -> void:
	current_energy = maxi(0, current_energy - amount)


# ---------------------------------------------------------------------------
# Factory methods
# ---------------------------------------------------------------------------

## Build from GameState (player entering combat).
static func from_game_state() -> CombatEntity:
	var e        := CombatEntity.new()
	e.is_player  = true
	e.name_th    = GameState.character_name
	e.name_en    = GameState.character_name
	var s        := GameState.stats
	e.max_hp        = maxi(1, int(s.get("hp",          100)))
	e.current_hp    = e.max_hp
	e.max_energy    = maxi(1, int(s.get("energy",       10)))
	e.current_energy = e.max_energy
	e.atk           = maxi(1, int(s.get("atk",          10)))
	e.defense       = maxi(0, int(s.get("def",           5)))
	e.spd           = maxi(1, int(s.get("spd",           8)))
	e.crit_rate     = float(s.get("crit_rate",         0.05))
	e.crit_dmg      = float(s.get("crit_dmg",          0.50))
	e.all_dmg       = float(s.get("all_dmg",           0.0))
	e.hp_regen      = int(s.get("hp_regen",              0))
	e.energy_regen  = int(s.get("energy_regen",           1))
	return e


## Build from Supabase enemy_template row (or hardcoded dict).
static func from_template(tmpl: Dictionary) -> CombatEntity:
	var e              := CombatEntity.new()
	e.is_player        = false
	e.template_id      = str(tmpl.get("id",             ""))
	e.name_th          = tmpl.get("name_th",     "มอนสเตอร์")
	e.name_en          = tmpl.get("name_en",       "Monster")
	e.max_hp           = maxi(1, int(tmpl.get("hp",      50)))
	e.current_hp       = e.max_hp
	e.max_energy       = maxi(1, int(tmpl.get("energy",  10)))
	e.current_energy   = e.max_energy
	e.atk              = maxi(1, int(tmpl.get("atk",      8)))
	e.defense          = maxi(0, int(tmpl.get("defense",  3)))
	e.spd              = maxi(1, int(tmpl.get("spd",      6)))
	e.crit_rate        = float(tmpl.get("crit_rate",   0.05))
	e.crit_dmg         = float(tmpl.get("crit_dmg",   0.50))
	e.hp_regen         = int(tmpl.get("hp_regen",         0))
	e.energy_regen     = int(tmpl.get("energy_regen",     1))
	e.archetype        = tmpl.get("ai_archetype",  "berserker")
	e.durability_mult  = float(tmpl.get("durability_damage_mult", 1.0))
	e.is_capturable    = bool(tmpl.get("is_capturable",   true))
	e.capture_base_rate = float(tmpl.get("capture_base_rate", 0.25))
	return e
