extends Node
## Stat calculation: base + divinity bonus + equipment affixes + skill nodes.
## Production: server recomputes via Supabase and writes to player_stat_cache.
## Local: preview-only (equip compare, skill tree hover).

# Base stats at divinity level 0 before any equipment or nodes
const BASE_STATS := {
	"hp": 100, "energy": 10,
	"atk": 10, "def": 5, "spd": 8,
	"crit_rate": 0.05, "crit_dmg": 1.5,
	"fire_dmg": 0.0, "ice_dmg": 0.0, "lightning_dmg": 0.0,
	"all_dmg": 0.0, "cooldown_reduce": 0.0,
	"hp_regen": 0, "energy_regen": 0,
}

# Cumulative bonus per divinity level (index 0 = Challenger, 10 = Theppakronam)
const DIVINITY_BONUS: Array[Dictionary] = [
	{},  # 0 — ผู้ท้าชิง
	{"hp": 20, "atk": 2, "def": 1},
	{"hp": 40, "atk": 4, "def": 2, "spd": 1},
	{"hp": 70, "atk": 7, "def": 4, "spd": 2},
	{"hp": 110, "atk": 11, "def": 7, "spd": 3, "energy": 2},
	{"hp": 160, "atk": 16, "def": 11, "spd": 5, "energy": 3, "crit_rate": 0.03},
	{"hp": 220, "atk": 22, "def": 16, "spd": 7, "energy": 5, "crit_rate": 0.05},
	{"hp": 300, "atk": 30, "def": 22, "spd": 10, "energy": 7, "crit_rate": 0.07, "crit_dmg": 0.20},
	{"hp": 400, "atk": 40, "def": 30, "spd": 13, "energy": 10, "crit_rate": 0.10, "crit_dmg": 0.30},
	{"hp": 550, "atk": 55, "def": 42, "spd": 18, "energy": 13, "crit_rate": 0.12, "crit_dmg": 0.40},
	{"hp": 800, "atk": 80, "def": 60, "spd": 25, "energy": 20, "crit_rate": 0.15, "crit_dmg": 0.50, "all_dmg": 0.10},
]

signal stats_refreshed


# ---------------------------------------------------------------------------
# Server sync
# ---------------------------------------------------------------------------

## Request server to recompute and cache stats, then pull the result.
## เรียกหลัง equip item, unlock skill node, หรือ divinity level up
func request_refresh() -> void:
	if GameState.is_guest:
		_apply_local()
		return
	if GameState.character_id.is_empty():
		return

	SupabaseClient.request_completed.connect(_on_cache_received, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_cache_failed, CONNECT_ONE_SHOT)
	SupabaseClient.db_get("player_stat_cache",
		"?player_id=eq." + GameState.character_id + "&select=*")


func _on_cache_received(data: Variant) -> void:
	if data is Array and not (data as Array).is_empty():
		var row = (data as Array)[0]
		if row is Dictionary:
			_apply_row(row)
			return
	_apply_local()  # cache miss — fallback


func _on_cache_failed(_code: int, _msg: String) -> void:
	_apply_local()


func _apply_row(row: Dictionary) -> void:
	for key in BASE_STATS.keys():
		if row.has(key):
			GameState.stats[key] = row[key]
	stats_refreshed.emit()
	GameState.stats_updated.emit()


# ---------------------------------------------------------------------------
# Local computation (guest + preview)
# ---------------------------------------------------------------------------

func _apply_local() -> void:
	GameState.stats = _compute([], [])
	stats_refreshed.emit()
	GameState.stats_updated.emit()


## Compute stats given additional node_bonuses and equipment_bonuses for preview.
## node_bonuses: Array[Dictionary] — each dict is {stat: value}
## equipment_bonuses: Array[Dictionary] — same format
func preview(node_bonuses: Array, equipment_bonuses: Array) -> Dictionary:
	return _compute(node_bonuses, equipment_bonuses)


func _compute(node_bonuses: Array, equipment_bonuses: Array) -> Dictionary:
	var result := {}
	for key in BASE_STATS.keys():
		result[key] = BASE_STATS[key]

	# Divinity
	var div_bonus: Dictionary = DIVINITY_BONUS[clampi(GameState.divinity_level, 0, 10)]
	_add_bonuses(result, div_bonus)

	# Equipment
	for bonus in equipment_bonuses:
		_add_bonuses(result, bonus)

	# Skill nodes
	for bonus in node_bonuses:
		_add_bonuses(result, bonus)

	return result


func _add_bonuses(target: Dictionary, bonus: Dictionary) -> void:
	for key in bonus:
		target[key] = float(target.get(key, 0.0)) + float(bonus[key])


# ---------------------------------------------------------------------------
# Display helpers
# ---------------------------------------------------------------------------

const _PCT_STATS := ["crit_rate", "crit_dmg", "fire_dmg", "ice_dmg",
	"lightning_dmg", "all_dmg", "cooldown_reduce"]

static func format_stat(key: String, value: float) -> String:
	if key in _PCT_STATS:
		return "+%.1f%%" % (value * 100.0)
	return "+%d" % int(value)


static func stat_display_name(key: String) -> String:
	const NAMES := {
		"hp": "HP", "energy": "Energy",
		"atk": "ATK", "def": "DEF", "spd": "SPD",
		"crit_rate": "Crit Rate", "crit_dmg": "Crit DMG",
		"fire_dmg": "Fire DMG", "ice_dmg": "Ice DMG", "lightning_dmg": "Lightning DMG",
		"all_dmg": "All DMG", "cooldown_reduce": "CDR",
		"hp_regen": "HP Regen", "energy_regen": "Energy Regen",
	}
	return NAMES.get(key, key)
