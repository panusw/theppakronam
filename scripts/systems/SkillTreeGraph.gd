extends Node
class_name SkillTreeGraph
## In-memory skill tree graph built from Supabase data.
## Provides O(1) lookup for unlock eligibility and neighbor traversal.
## Load once per session via load_for_player(); reload after band change.

var _nodes: Dictionary     = {}   # node_id(str) → row(Dictionary)
var _edges_fwd: Dictionary = {}   # from_id → [to_id, ...]
var _edges_rev: Dictionary = {}   # to_id   → [from_id, ...]
var _unlocked: Dictionary  = {}   # node_id → true

var is_loaded := false

signal loaded
signal node_unlocked(node_id: String)
signal unlock_failed(node_id: String, reason: String)


func load_for_player(player_id: String) -> void:
	is_loaded = false
	_nodes.clear()
	_edges_fwd.clear()
	_edges_rev.clear()
	_unlocked.clear()
	_fetch_nodes(player_id)


# ---------------------------------------------------------------------------
# Sequential fetch: nodes → edges → player unlocked
# ---------------------------------------------------------------------------

func _fetch_nodes(player_id: String) -> void:
	SupabaseClient.request_completed.connect(_on_nodes.bind(player_id), CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_fetch_error.bind("nodes"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("skill_nodes", "?select=*&order=tier.asc")


func _on_nodes(data: Variant, player_id: String) -> void:
	if data is Array:
		for row in data:
			if row is Dictionary:
				_nodes[row["id"]] = row
	_fetch_edges(player_id)


func _fetch_edges(player_id: String) -> void:
	SupabaseClient.request_completed.connect(_on_edges.bind(player_id), CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_fetch_error.bind("edges"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("skill_edges", "?select=from_node,to_node")


func _on_edges(data: Variant, player_id: String) -> void:
	if data is Array:
		for row in data:
			if not row is Dictionary:
				continue
			var frm: String = row["from_node"]
			var to:  String = row["to_node"]
			if not _edges_fwd.has(frm): _edges_fwd[frm] = []
			_edges_fwd[frm].append(to)
			if not _edges_rev.has(to):  _edges_rev[to]  = []
			_edges_rev[to].append(frm)
	_fetch_unlocked(player_id)


func _fetch_unlocked(player_id: String) -> void:
	SupabaseClient.request_completed.connect(_on_unlocked, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_fetch_error.bind("unlocked"), CONNECT_ONE_SHOT)
	SupabaseClient.db_get("player_skill_nodes",
		"?player_id=eq." + player_id + "&select=node_id")


func _on_unlocked(data: Variant) -> void:
	if data is Array:
		for row in data:
			if row is Dictionary:
				_unlocked[row["node_id"]] = true
	is_loaded = true
	loaded.emit()


func _on_fetch_error(stage: String, _code: int, _msg: String) -> void:
	push_error("SkillTreeGraph: failed loading " + stage)
	# Emit loaded anyway so UI can show empty tree rather than freezing
	is_loaded = true
	loaded.emit()


# ---------------------------------------------------------------------------
# Query API
# ---------------------------------------------------------------------------

func get_all_nodes() -> Array:
	return _nodes.values()


func get_node(node_id: String) -> Dictionary:
	return _nodes.get(node_id, {})


func is_unlocked(node_id: String) -> bool:
	return _unlocked.get(node_id, false)


## Returns true if node can be unlocked right now (gold + divinity + adjacency).
func is_unlockable(node_id: String) -> bool:
	if is_unlocked(node_id):
		return false
	var node: Dictionary = _nodes.get(node_id, {})
	if node.is_empty():
		return false
	if int(node.get("divinity_req", 0)) > GameState.divinity_level:
		return false
	if int(node.get("unlock_cost_gold", 0)) > GameState.gold:
		return false
	var parents: Array = _edges_rev.get(node_id, [])
	if parents.is_empty():
		return true  # center node — no parent required
	for p in parents:
		if is_unlocked(p):
			return true
	return false


## All node_ids that pass unlock eligibility right now.
func get_unlockable_ids() -> Array:
	var result := []
	for node_id in _nodes.keys():
		if is_unlockable(node_id):
			result.append(node_id)
	return result


func get_children(node_id: String) -> Array:
	return _edges_fwd.get(node_id, [])


func get_parents(node_id: String) -> Array:
	return _edges_rev.get(node_id, [])


## Sum of all stat_bonuses across unlocked nodes — used by StatCalculator.
func get_total_node_bonuses() -> Dictionary:
	var total := {}
	for node_id in _unlocked.keys():
		var node: Dictionary = _nodes.get(node_id, {})
		var bonuses = node.get("stat_bonuses", {})
		if not bonuses is Dictionary:
			continue
		for key in bonuses:
			total[key] = float(total.get(key, 0.0)) + float(bonuses[key])
	return total


# ---------------------------------------------------------------------------
# Unlock
# ---------------------------------------------------------------------------

func unlock_node(node_id: String) -> void:
	if not is_unlockable(node_id):
		unlock_failed.emit(node_id, tr("SKILL_ERR_REQUIREMENTS"))
		return

	if GameState.is_guest:
		_unlock_local(node_id)
		return

	SupabaseClient.request_completed.connect(_on_unlock_done.bind(node_id), CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_unlock_error.bind(node_id), CONNECT_ONE_SHOT)
	SupabaseClient.call_rpc("unlock_skill_node", {
		"p_player_id": GameState.character_id,
		"p_node_id":   node_id,
	})


func _on_unlock_done(data: Variant, node_id: String) -> void:
	var row: Dictionary = {}
	if data is Array and not (data as Array).is_empty():
		row = (data as Array)[0]
	elif data is Dictionary:
		row = data

	if row.get("success", false):
		_apply_unlock(node_id, int(row.get("gold_spent", 0)))
	else:
		unlock_failed.emit(node_id, str(row))


func _on_unlock_error(node_id: String, _code: int, message: String) -> void:
	unlock_failed.emit(node_id, message)


func _unlock_local(node_id: String) -> void:
	var cost := int(_nodes[node_id].get("unlock_cost_gold", 0))
	_apply_unlock(node_id, cost)
	GameState.save_guest()


func _apply_unlock(node_id: String, gold_spent: int) -> void:
	_unlocked[node_id] = true
	GameState.gold -= gold_spent
	node_unlocked.emit(node_id)
