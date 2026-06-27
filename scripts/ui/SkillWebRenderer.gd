extends Control
class_name SkillWebRenderer
## Passive skill tree UI.
## Attaches to root SkillWeb Control in skill_web.tscn.
## Draws the graph inside a SubViewport; handles pan/click/unlock.

# ---------------------------------------------------------------------------
# Inner class: one per skill node visual inside the SubViewport
# ---------------------------------------------------------------------------

class _NodeVisual extends Node2D:
	var node_id:    String     = ""
	var data:       Dictionary = {}
	var unlocked:   bool       = false
	var unlockable: bool       = false
	var selected:   bool       = false

	const R := 20.0
	const TIER_COLORS: Array[Color] = [
		Color("#4f8aec"),   # tier 1
		Color("#44bb6a"),   # tier 2
		Color("#e0c030"),   # tier 3
		Color("#e06020"),   # tier 4
		Color("#cc44ee"),   # tier 5
	]

	func _draw() -> void:
		var tier_idx := clampi(int(data.get("tier", 1)) - 1, 0, 4)
		var base_col := TIER_COLORS[tier_idx]

		var fill_col: Color
		if unlocked:
			fill_col = base_col
		elif unlockable:
			fill_col = base_col.lerp(Color.WHITE, 0.4)
		else:
			fill_col = Color(0.2, 0.2, 0.25, 1.0)

		var border_col := Color.GOLD if selected else (Color.WHITE if unlockable else Color(0.5, 0.5, 0.6))
		var border_w   := 3.0 if selected else 1.5

		draw_circle(Vector2.ZERO, R, fill_col)
		# Border ring
		for i in 32:
			var a0 := float(i)     / 32.0 * TAU
			var a1 := float(i + 1) / 32.0 * TAU
			draw_line(Vector2(cos(a0), sin(a0)) * R,
					  Vector2(cos(a1), sin(a1)) * R,
					  border_col, border_w)

		# Lock icon for locked nodes
		if not unlocked and not unlockable:
			draw_string(ThemeDB.fallback_font,
				Vector2(-6, 5), "🔒", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.GRAY)
		elif unlocked:
			draw_string(ThemeDB.fallback_font,
				Vector2(-6, 5), "✓", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

		# Name label below the node
		var name_th: String = data.get("name_th", "")
		draw_string(ThemeDB.fallback_font,
			Vector2(-40, R + 14), name_th,
			HORIZONTAL_ALIGNMENT_LEFT, 80, 11, Color.WHITE if unlocked else Color(0.7, 0.7, 0.7))

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _viewport:     SubViewportContainer = $GraphViewport
@onready var _subvp:        SubViewport          = $GraphViewport/GraphSubViewport
@onready var _edge_lines:   Node2D               = $GraphViewport/GraphSubViewport/GraphRoot/EdgeLines
@onready var _node_sprites: Node2D               = $GraphViewport/GraphSubViewport/GraphRoot/NodeSprites
@onready var _camera:       Camera2D             = $GraphViewport/GraphSubViewport/GraphRoot/Camera2D
@onready var _lbl_name:     Label                = $SidePanel/NodeName
@onready var _lbl_desc:     RichTextLabel        = $SidePanel/NodeDesc
@onready var _lbl_cost:     Label                = $SidePanel/UnlockCost
@onready var _btn_unlock:   Button               = $SidePanel/BtnUnlock
@onready var _btn_close:    Button               = $SidePanel/BtnClose

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

const GRID_SCALE := Vector2(130.0, 110.0)

var _node_visuals:   Dictionary = {}   # node_id → _NodeVisual
var _node_positions: Dictionary = {}   # node_id → Vector2 world
var _selected_id:    String     = ""
var _pan_origin:     Vector2    = Vector2.ZERO
var _cam_origin:     Vector2    = Vector2.ZERO
var _is_panning:     bool       = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_lbl_name.text    = "เลือก Node"
	_lbl_desc.text    = ""
	_lbl_cost.text    = ""
	_btn_unlock.disabled = true
	_btn_unlock.pressed.connect(_on_unlock_pressed)
	_btn_close.pressed.connect(_on_close)
	_viewport.gui_input.connect(_on_graph_gui_input)

	SkillTreeGraph.node_unlocked.connect(_on_node_unlocked)
	SkillTreeGraph.unlock_failed.connect(_on_unlock_failed)

	if SkillTreeGraph.is_loaded:
		_build_graph()
	else:
		SkillTreeGraph.loaded.connect(_build_graph, CONNECT_ONE_SHOT)
		if not GameState.is_guest:
			SkillTreeGraph.load_for_player(GameState.character_id)
		else:
			SkillTreeGraph.loaded.emit()  # empty graph for guest

# ---------------------------------------------------------------------------
# Graph construction
# ---------------------------------------------------------------------------

func _build_graph() -> void:
	# Clear old visuals
	for c in _edge_lines.get_children():  c.queue_free()
	for c in _node_sprites.get_children(): c.queue_free()
	_node_visuals.clear()
	_node_positions.clear()

	var nodes := SkillTreeGraph.get_all_nodes()

	# Build position map
	for node in nodes:
		var nid := str(node.get("id", ""))
		if nid.is_empty():
			continue
		var wx := float(node.get("pos_x", 0.0)) * GRID_SCALE.x
		var wy := float(node.get("pos_y", 0.0)) * GRID_SCALE.y
		_node_positions[nid] = Vector2(wx, wy)

	# Draw edges first (Line2D)
	for node in nodes:
		var nid := str(node.get("id", ""))
		for child_id in SkillTreeGraph.get_node_children(nid):
			if not _node_positions.has(nid) or not _node_positions.has(child_id):
				continue
			var line        := Line2D.new()
			line.width      = 1.5
			line.default_color = Color(0.4, 0.4, 0.6, 0.7)
			line.add_point(_node_positions[nid])
			line.add_point(_node_positions[child_id])
			_edge_lines.add_child(line)

	# Draw nodes
	for node in nodes:
		var nid := str(node.get("id", ""))
		if not _node_positions.has(nid):
			continue
		var vis        := _NodeVisual.new()
		vis.node_id    = nid
		vis.data       = node
		vis.unlocked   = SkillTreeGraph.is_unlocked(nid)
		vis.unlockable = SkillTreeGraph.is_unlockable(nid)
		vis.position   = _node_positions[nid]
		_node_sprites.add_child(vis)
		_node_visuals[nid] = vis

	# Center camera on center node (tier 1 universal — no band)
	_center_camera_on_start(nodes)

	_refresh_edge_colors()


func _center_camera_on_start(nodes: Array) -> void:
	for node in nodes:
		if int(node.get("tier", 0)) == 1 and node.get("band_id") == null:
			var nid := str(node.get("id", ""))
			if _node_positions.has(nid):
				_camera.position = _node_positions[nid]
				return
	# Fallback: average of all positions
	if _node_positions.is_empty():
		return
	var avg := Vector2.ZERO
	for pos in _node_positions.values():
		avg += pos
	_camera.position = avg / float(_node_positions.size())


func _refresh_edge_colors() -> void:
	# Highlight edges connected to unlocked nodes
	var idx := 0
	var nodes := SkillTreeGraph.get_all_nodes()
	for node in nodes:
		var nid := str(node.get("id", ""))
		var children_ids := SkillTreeGraph.get_node_children(nid)
		for child_id in children_ids:
			if idx < _edge_lines.get_child_count():
				var line: Line2D = _edge_lines.get_child(idx) as Line2D
				if line:
					var both_unlocked := SkillTreeGraph.is_unlocked(nid) \
						and SkillTreeGraph.is_unlocked(child_id)
					line.default_color = Color("#e0c030", 0.85) if both_unlocked \
						else Color(0.4, 0.4, 0.6, 0.7)
			idx += 1

# ---------------------------------------------------------------------------
# Graph input (pan + click)
# ---------------------------------------------------------------------------

func _on_graph_gui_input(event: InputEvent) -> void:
	# Pan: middle mouse button drag
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			if mb.pressed:
				_is_panning = true
				_pan_origin = mb.position
				_cam_origin = _camera.position
			else:
				_is_panning = false

		# Click: left button
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var world := _vp_to_world(mb.position)
			_try_select_node(world)

	if event is InputEventMouseMotion and _is_panning:
		var delta := (event as InputEventMouseMotion).position - _pan_origin
		_camera.position = _cam_origin - delta


## Convert SubViewportContainer local position → SubViewport world position.
func _vp_to_world(local_pos: Vector2) -> Vector2:
	var vp_size := Vector2(_subvp.size)
	var ct_size := _viewport.size
	# Scale from container pixels to SubViewport pixels
	var ratio  := vp_size / ct_size if ct_size != Vector2.ZERO else Vector2.ONE
	var vp_px  := local_pos * ratio
	# Convert SubViewport pixel → world (account for Camera2D center)
	return vp_px - vp_size * 0.5 + _camera.position


func _try_select_node(world_pos: Vector2) -> void:
	const CLICK_RADIUS := 24.0
	var best_id    := ""
	var best_dist  := CLICK_RADIUS * CLICK_RADIUS

	for nid in _node_positions.keys():
		var d2 := world_pos.distance_squared_to(_node_positions[nid])
		if d2 < best_dist:
			best_dist = d2
			best_id   = nid

	if best_id.is_empty():
		_deselect()
		return

	if _selected_id == best_id:
		return  # already selected

	# Deselect old
	if _node_visuals.has(_selected_id):
		(_node_visuals[_selected_id] as _NodeVisual).selected = false
		(_node_visuals[_selected_id] as _NodeVisual).queue_redraw()

	_selected_id = best_id
	var vis := _node_visuals[_selected_id] as _NodeVisual
	vis.selected = true
	vis.queue_redraw()

	_show_side_panel(SkillTreeGraph.get_skill_node(_selected_id))


func _deselect() -> void:
	if _node_visuals.has(_selected_id):
		(_node_visuals[_selected_id] as _NodeVisual).selected = false
		(_node_visuals[_selected_id] as _NodeVisual).queue_redraw()
	_selected_id = ""
	_lbl_name.text = "เลือก Node"
	_lbl_desc.text = ""
	_lbl_cost.text = ""
	_btn_unlock.disabled = true

# ---------------------------------------------------------------------------
# Side panel
# ---------------------------------------------------------------------------

func _show_side_panel(node: Dictionary) -> void:
	if node.is_empty():
		return

	_lbl_name.text = node.get("name_th", "—")

	# Description: stat bonuses + passive desc
	var desc := ""
	var bonuses = node.get("stat_bonuses", {})
	if bonuses is Dictionary and not bonuses.is_empty():
		desc += "[color=yellow]Stat Bonuses:[/color]\n"
		for stat in bonuses:
			desc += "  %s +%s\n" % [stat, str(bonuses[stat])]
	var passive_th: String = node.get("passive_desc_th", "")
	if not passive_th.is_empty():
		desc += "\n[color=cyan]%s[/color]" % passive_th
	_lbl_desc.text = desc

	# Cost
	var gold_cost := int(node.get("unlock_cost_gold", 0))
	var div_req   := int(node.get("divinity_req", 0))
	var nid       := str(node.get("id", ""))
	var unlocked  := SkillTreeGraph.is_unlocked(nid)
	var unlockable := SkillTreeGraph.is_unlockable(nid)

	if unlocked:
		_lbl_cost.text    = "✓ ปลดล็อกแล้ว"
		_btn_unlock.disabled = true
	else:
		var cost_parts: Array[String] = []
		if gold_cost > 0:
			cost_parts.append("Gold %d" % gold_cost)
		if div_req > 0:
			cost_parts.append("Divinity Lv.%d" % div_req)
		_lbl_cost.text       = "ค่าปลดล็อก: " + (", ".join(cost_parts) if not cost_parts.is_empty() else "ฟรี")
		_btn_unlock.disabled = not unlockable

# ---------------------------------------------------------------------------
# Button handlers
# ---------------------------------------------------------------------------

func _on_unlock_pressed() -> void:
	if _selected_id.is_empty():
		return
	_btn_unlock.disabled = true
	_btn_unlock.text     = "กำลังปลดล็อก..."
	SkillTreeGraph.unlock_node(_selected_id)


func _on_close() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

# ---------------------------------------------------------------------------
# SkillTreeGraph callbacks
# ---------------------------------------------------------------------------

func _on_node_unlocked(node_id: String) -> void:
	_btn_unlock.text = "ปลดล็อก"
	if _node_visuals.has(node_id):
		var vis := _node_visuals[node_id] as _NodeVisual
		vis.unlocked   = true
		vis.unlockable = false
		vis.queue_redraw()

	# Refresh all unlockable states (new neighbors may become available)
	for nid in _node_visuals.keys():
		var vis := _node_visuals[nid] as _NodeVisual
		var was := vis.unlockable
		vis.unlockable = SkillTreeGraph.is_unlockable(nid)
		if was != vis.unlockable:
			vis.queue_redraw()

	_refresh_edge_colors()

	# Refresh side panel if this node is currently selected
	if _selected_id == node_id:
		_show_side_panel(SkillTreeGraph.get_skill_node(node_id))


func _on_unlock_failed(_node_id: String, reason: String) -> void:
	_btn_unlock.text     = "ปลดล็อก"
	_btn_unlock.disabled = false
	_lbl_cost.text       = "⚠ %s" % reason
