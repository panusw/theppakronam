extends Node
## Singleton — game time, day/night cycle, and season tracking.
## 1 real hour = 1 full day/night cycle.
## Season follows Pantheon per Band (defined in GAME_DESIGN §44).

const REAL_SECONDS_PER_CYCLE: float = 3600.0
const DAY_START_FRACTION: float  = 0.25   # 06:00
const NIGHT_START_FRACTION: float = 0.75  # 18:00

var _elapsed_seconds: float = 0.0
var is_night: bool = false

enum Season { SPRING, SUMMER, AUTUMN, WINTER }
var current_season: Season = Season.SPRING

signal time_of_day_changed(is_night: bool)
signal season_changed(season: Season)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_elapsed_seconds += delta
	var frac: float = get_cycle_fraction()
	var night_now: bool = frac >= NIGHT_START_FRACTION or frac < DAY_START_FRACTION
	if night_now != is_night:
		is_night = night_now
		time_of_day_changed.emit(is_night)


# --- Public ---

func get_cycle_fraction() -> float:
	return fmod(_elapsed_seconds, REAL_SECONDS_PER_CYCLE) / REAL_SECONDS_PER_CYCLE


func get_hour_24() -> int:
	return int(get_cycle_fraction() * 24.0)


func get_time_label() -> String:
	var h: int = get_hour_24()
	var m: int = int(get_cycle_fraction() * 24.0 * 60.0) % 60
	return "%02d:%02d" % [h, m]


func sync_from_server(server_game_seconds: float) -> void:
	_elapsed_seconds = server_game_seconds
