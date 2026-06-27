extends Node2D
class_name CampGraphRenderer
## Renders the tower camp graph using draw_* calls.
## Handles hover + click detection in world space (works with Camera2D zoom/pan).

const CAMP_RADIUS := 22.0
const GRID_SCALE  := Vector2(150.0, 130.0)  # world px per grid unit

const COLOR_CURRENT  := Color("#f0c040")   # gold — current position
const COLOR_VISITED  := Color("#4fae6e")   # green — cleared/visited
const COLOR_ADJACENT := Color("#3f8fe0")   # blue — reachable next step
const COLOR_LOCKED   := Color("#55667a")   # gray — not yet accessible
const COLOR_BOSS     := Color("#cc3322")   # red — boss / mini-boss
const COLOR_EDGE     := Color(1.0, 1.0, 1.0, 0.18)
const COLOR_EDGE_ADJ := Color(1.0, 1.0, 1.0, 0.70)
const COLOR_LABEL    := Color(1.0, 1.0, 1.0, 0.92)
const COLOR_SHADOW   := Color(0.0, 0.0, 0.0, 0.45)

const ICON := {
	"spawn":        "★",
	"normal":       "●",
	"elite":        "◆",
	"mini_boss":    "☠",
	"checkpoint":   "⛩",
	"boss_gate":    "⛔",
	"boss":         "♛",
	"resource":     "⛏",
	"mystery":      "?",
	"hunting_zone": "⚐",
	"hub":          "⌂",
}

var _camps:       Array[Dictionary] = []
var _connections: Array[Dictionary] = []
var _visited:     Dictionary = {}   # camp_id → row
var _current_id:  String = ""
var _positions:   Dictionary = {}   # camp_id → Vector2 (local coords)
var _hovered_id:  String = ""

signal camp_clicked(camp_id: String)


func set_data(
	camps:       Array[Dictionary],
	connections: Array[Dictionary],
	visited:     Dictionary,
	current_id:  String
) -> void:
	_camps       = camps
	_connections = connections
	_visited     = visited
	_current_id  = current_id
	_rebuild_positions()
	queue_redraw()


## Returns the world-space position of a camp node (for camera targeting).
func get_camp_position(camp_id: String) -> Vector2:
	return _positions.get(camp_id, Vector2.ZERO)


func _rebuild_positions() -> void:
	_positions.clear()
	if _camps.is_empty():
		return
	# Offset so minimum pos is (0,0)
	var min_x := INF
	var min_y := INF
	for c in _camps:
		min_x = minf(min_x, float(c.get("pos_x", 0)))
		min_y = minf(min_y, float(c.get("pos_y", 0)))
	for c in _camps:
		var gx := float(c.get("pos_x", 0)) - min_x
		var gy := float(c.get("pos_y", 0)) - min_y
		_positions[c["id"]] = Vector2(gx * GRID_SCALE.x, gy * GRID_SCALE.y)


func _draw() -> void:
	var font := ThemeDB.fallback_font

	# --- Edges ---
	for conn in _connections:
		var a: String = conn.get("from_camp", "")
		var b: String = conn.get("to_camp", "")
		if not (_positions.has(a) and _positions.has(b)):
			continue
		var is_active := (a == _current_id or b == _current_id)
		draw_line(_positions[a], _positions[b],
			COLOR_EDGE_ADJ if is_active else COLOR_EDGE, 2.5, true)

	# --- Nodes ---
	for camp in _camps:
		var cid:       String  = camp["id"]
		var pos:       Vector2 = _positions.get(cid, Vector2.ZERO)
		var ctype:     String  = camp.get("camp_type", "normal")
		var col:       Color   = _node_color(cid, ctype)

		# Drop shadow
		draw_circle(pos + Vector2(2, 3), CAMP_RADIUS, COLOR_SHADOW)
		# Fill
		draw_circle(pos, CAMP_RADIUS, col)
		# Hover ring
		if cid == _hovered_id:
			draw_arc(pos, CAMP_RADIUS + 4, 0, TAU, 32, Color.WHITE, 2.0)
		# Current-position ring
		if cid == _current_id:
			draw_arc(pos, CAMP_RADIUS + 2, 0, TAU, 32, COLOR_CURRENT, 3.0)

		# Icon (centered inside circle)
		var icon: String = ICON.get(ctype, "●")
		var iw := font.get_string_size(icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		draw_string(font, pos + Vector2(-iw * 0.5, 6),
			icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, COLOR_LABEL)

		# Camp name below node
		var name_th: String = camp.get("name_th", "")
		draw_string(font, pos + Vector2(-60, CAMP_RADIUS + 16),
			name_th, HORIZONTAL_ALIGNMENT_CENTER, 120, 11, COLOR_LABEL)


func _node_color(cid: String, ctype: String) -> Color:
	if cid == _current_id:
		return COLOR_CURRENT
	if _visited.has(cid):
		return COLOR_VISITED
	if ctype in ["boss", "mini_boss"]:
		return COLOR_BOSS
	if _is_adjacent(cid):
		return COLOR_ADJACENT
	return COLOR_LOCKED


func _is_adjacent(cid: String) -> bool:
	if _current_id.is_empty():
		return false
	for conn in _connections:
		var f: String = conn.get("from_camp", "")
		var t: String = conn.get("to_camp", "")
		if (f == _current_id and t == cid) or (t == _current_id and f == cid):
			return true
	return false


func _process(_delta: float) -> void:
	var world_mouse := get_global_mouse_position()
	var new_hover   := ""
	for cid in _positions:
		if world_mouse.distance_to(_positions[cid]) <= CAMP_RADIUS + 4.0:
			new_hover = cid
			break
	if new_hover != _hovered_id:
		_hovered_id = new_hover
		queue_redraw()


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mev := event as InputEventMouseButton
	if not mev.pressed or mev.button_index != MOUSE_BUTTON_LEFT:
		return
	var world_mouse := get_global_mouse_position()
	for cid in _positions:
		if world_mouse.distance_to(_positions[cid]) <= CAMP_RADIUS + 4.0:
			camp_clicked.emit(cid)
			get_viewport().set_input_as_handled()
			return
