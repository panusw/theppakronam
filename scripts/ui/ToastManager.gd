extends Node
class_name ToastManager
## Singleton for transient toast notifications.
## Add as autoload; scene uses %ToastContainer if available.
## Usage: ToastManager.show("ข้อความ")  or  .show("msg", Color.RED, 3.0)

const DEFAULT_DURATION := 2.5
const FADE_TIME        := 0.35

var _container: VBoxContainer = null


func _ready() -> void:
	# Try to find a ToastContainer in current scene; re-check on scene change
	get_tree().tree_changed.connect(_find_container)
	_find_container()


func _find_container() -> void:
	await get_tree().process_frame
	var root := get_tree().current_scene
	if root == null:
		_container = null
		return
	# Try unique-name lookup first (%ToastContainer)
	var found := root.find_child("ToastContainer", true, false)
	_container = found as VBoxContainer


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Show a toast. color defaults to white; duration in seconds.
func show(message: String,
		  color: Color = Color.WHITE,
		  duration: float = DEFAULT_DURATION) -> void:
	if _container == null:
		push_warning("ToastManager: no ToastContainer in scene — '%s'" % message)
		return
	_spawn_toast(message, color, duration)


func show_ok(message: String, duration: float = DEFAULT_DURATION) -> void:
	show(message, Color("#44dd88"), duration)


func show_warn(message: String, duration: float = DEFAULT_DURATION) -> void:
	show(message, Color("#ffcc44"), duration)


func show_err(message: String, duration: float = DEFAULT_DURATION) -> void:
	show(message, Color("#ff5555"), duration)


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _spawn_toast(message: String, color: Color, duration: float) -> void:
	var lbl := Label.new()
	lbl.text = message
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.modulate.a = 0.0
	_container.add_child(lbl)

	# Fade in → hold → fade out → free
	var tw := lbl.create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, FADE_TIME)
	tw.tween_interval(duration)
	tw.tween_property(lbl, "modulate:a", 0.0, FADE_TIME)
	tw.tween_callback(lbl.queue_free)
