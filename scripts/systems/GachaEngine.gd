extends Node
## Gacha pull system — pity tracking, weighted rarity roll, item selection.
## Authenticated players: server-authoritative pull via gacha_pull RPC.
## Guest players: local roll (no anti-cheat needed for offline data).

const RARITY_WEIGHTS := {
	"common": 45.0, "uncommon": 25.0, "rare": 18.0,
	"epic": 9.0, "legendary": 2.7, "mythic": 0.3,
}
const PITY_THRESHOLD    := 50    # pulls until guaranteed epic+
const COST_SINGLE       := 100   # gems per pull
const COST_MULTI        := 900   # gems for x10
const EPIC_PLUS         := ["epic", "legendary", "mythic"]

# Item pool cached from Supabase (gacha-eligible types only)
var _pool: Array[Dictionary] = []
var _pool_loaded := false

signal pull_completed(items: Array)   # Array[Dictionary]
signal pull_failed(message: String)
signal pool_ready


func pull_single() -> void:
	_start_pull(1)


func pull_multi() -> void:
	_start_pull(10)


func _start_pull(count: int) -> void:
	var cost := COST_SINGLE if count == 1 else COST_MULTI
	if GameState.gems < cost:
		pull_failed.emit(tr("GACHA_ERR_NO_GEMS"))
		return

	if GameState.is_guest:
		if not _pool_loaded:
			_build_fallback_pool()
		_pull_local(count, cost)
		return

	SupabaseClient.request_completed.connect(_on_pull_done, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_pull_error, CONNECT_ONE_SHOT)
	SupabaseClient.call_rpc("gacha_pull", {
		"p_player_id": GameState.character_id,
		"p_count":     count,
	})


func _on_pull_done(data: Variant) -> void:
	var row: Dictionary = {}
	if data is Array and not (data as Array).is_empty():
		row = (data as Array)[0]
	elif data is Dictionary:
		row = data

	GameState.gems        = row.get("gems_remaining", GameState.gems)
	GameState.gacha_pity  = row.get("pity", GameState.gacha_pity)
	pull_completed.emit(row.get("items", []))


func _on_pull_error(code: int, message: String) -> void:
	pull_failed.emit("(%d) %s" % [code, message])


# ---------------------------------------------------------------------------
# Guest / offline roll
# ---------------------------------------------------------------------------

func _pull_local(count: int, cost: int) -> void:
	GameState.gems -= cost
	var results: Array = []

	for _i in count:
		var rarity := _roll_rarity(GameState.gacha_pity)
		GameState.gacha_pity += 1
		if rarity in EPIC_PLUS:
			GameState.gacha_pity = 0

		var item := _pick_from_pool(rarity)
		if not item.is_empty():
			results.append(item)
			GameState.inventory.append(item)

	GameState.save_guest()
	pull_completed.emit(results)


func _roll_rarity(pity: int) -> String:
	if pity >= PITY_THRESHOLD - 1:
		return _weighted_pick(["epic", "legendary", "mythic"], [75.0, 20.0, 5.0])
	return _weighted_pick(RARITY_WEIGHTS.keys(), RARITY_WEIGHTS.values())


func _weighted_pick(keys: Array, weights: Array) -> String:
	var total := 0.0
	for w in weights:
		total += float(w)
	var roll := randf() * total
	var acc := 0.0
	for i in keys.size():
		acc += float(weights[i])
		if roll <= acc:
			return keys[i]
	return keys[-1]


func _pick_from_pool(rarity: String) -> Dictionary:
	var subset := _pool.filter(func(it): return it.get("rarity", "") == rarity)
	if subset.is_empty():
		subset = _pool.filter(func(it): return it.get("rarity", "") == "common")
	if subset.is_empty():
		return {}
	return subset[randi() % subset.size()]


# ---------------------------------------------------------------------------
# Pool loading
# ---------------------------------------------------------------------------

## โหลด pool จาก Supabase — เรียกครั้งเดียวเมื่อ GachaPanel เปิด
func load_pool() -> void:
	if _pool_loaded:
		pool_ready.emit()
		return
	if GameState.is_guest:
		_build_fallback_pool()
		pool_ready.emit()
		return
	SupabaseClient.request_completed.connect(_on_pool_loaded, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_pool_load_failed, CONNECT_ONE_SHOT)
	SupabaseClient.db_get("items",
		"?item_type=in.(skill_node,weapon,armor,rune,ore)&select=id,name_th,name_en,item_type,rarity,base_value")


func _on_pool_loaded(data: Variant) -> void:
	_pool.clear()
	if data is Array:
		for item in data:
			if item is Dictionary:
				_pool.append(item)
	_pool_loaded = true
	pool_ready.emit()


func _on_pool_load_failed(_code: int, _msg: String) -> void:
	_build_fallback_pool()
	pool_ready.emit()


func _build_fallback_pool() -> void:
	_pool = [
		{"name_th": "โหนดพลังงาน I",  "name_en": "Energy Node I",    "item_type": "skill_node", "rarity": "common"},
		{"name_th": "โหนดโจมตี I",     "name_en": "Attack Node I",    "item_type": "skill_node", "rarity": "common"},
		{"name_th": "โหนดป้องกัน I",   "name_en": "Defense Node I",   "item_type": "skill_node", "rarity": "common"},
		{"name_th": "โหนดความเร็ว I",  "name_en": "Speed Node I",     "item_type": "skill_node", "rarity": "uncommon"},
		{"name_th": "โหนดวิกฤต I",     "name_en": "Crit Node I",      "item_type": "skill_node", "rarity": "uncommon"},
		{"name_th": "โหนดแห่งไฟ",      "name_en": "Fire Node",        "item_type": "skill_node", "rarity": "rare"},
		{"name_th": "โหนดมหาพลัง",     "name_en": "Grand Power Node", "item_type": "skill_node", "rarity": "epic"},
		{"name_th": "รูนแสง I",         "name_en": "Light Rune I",     "item_type": "rune",       "rarity": "common"},
		{"name_th": "รูนมืด I",         "name_en": "Dark Rune I",      "item_type": "rune",       "rarity": "uncommon"},
		{"name_th": "รูนไฟ",            "name_en": "Fire Rune",        "item_type": "rune",       "rarity": "rare"},
		{"name_th": "แร่ทองแดง",        "name_en": "Copper Ore",       "item_type": "ore",        "rarity": "common"},
		{"name_th": "แร่เงิน",          "name_en": "Silver Ore",       "item_type": "ore",        "rarity": "uncommon"},
		{"name_th": "แร่ทอง",           "name_en": "Gold Ore",         "item_type": "ore",        "rarity": "rare"},
		{"name_th": "แร่มิทริล",        "name_en": "Mithril Ore",      "item_type": "ore",        "rarity": "epic"},
		{"name_th": "ดาบโบราณ",         "name_en": "Ancient Sword",    "item_type": "weapon",     "rarity": "uncommon"},
		{"name_th": "หอกผี",            "name_en": "Ghost Spear",      "item_type": "weapon",     "rarity": "rare"},
		{"name_th": "คันธนูลม",         "name_en": "Wind Bow",         "item_type": "weapon",     "rarity": "rare"},
		{"name_th": "คทาดาว",           "name_en": "Star Staff",       "item_type": "weapon",     "rarity": "epic"},
	]
	_pool_loaded = true
