extends Node
## Singleton — player session data and current game state.
## All stat-sensitive fields are server-authoritative; this is a local cache only.

# --- Auth ---
var auth_token: String = ""
var player_id: String = ""
var is_guest: bool = false

# --- Character ---
var character_id: String = ""
var character_name: String = ""
var pending_appearance: Dictionary = {}  # set by CharacterCreator, cleared after save
var difficulty: String = "normal"  # normal / hard / ascendant / eternal

# --- Divinity ---
var divinity_level: int = 0
var divinity_exp: int = 0

const DIVINITY_TITLES: Array[String] = [
	"ผู้ท้าชิง", "ผู้แสวงหา", "นักสำรวจ", "ขุนศึก", "วีรบุรุษ",
	"เซียน", "ผู้รู้แจ้ง", "เทพบุตร", "เทพเจ้า", "เทพสูงสุด", "เทพปกรณัม"
]

# --- Stats (cached from server player_stat_cache) ---
var stats: Dictionary = {
	"hp": 0, "energy": 10, "atk": 0, "def": 0, "spd": 0,
	"crit_rate": 0.05, "crit_dmg": 1.5,
	"fire_dmg": 0.0, "ice_dmg": 0.0, "lightning_dmg": 0.0,
	"all_dmg": 0.0, "cooldown_reduce": 0.0,
	"hp_regen": 0.0, "energy_regen": 0.0,
}

# --- Energy ---
var world_energy: int = 100   # ⚡ travel cost
var battle_energy: int = 10   # 🔋 combat cost

# --- Survival ---
var hunger: float = 100.0
var thirst: float = 100.0
var fatigue: float = 100.0

# --- Economy ---
var gold: int = 0
var gems: int = 0
var gacha_pity: int = 0  # resets on epic+

# --- Tower position ---
var current_band: int = 1
var current_floor: int = 1
var current_camp_id: String = ""
var current_camp_type: String = "normal"

# --- Inventory (lightweight manifest; full data fetched per-session) ---
var inventory: Array[Dictionary] = []

# --- Signals ---
signal stats_updated
signal energy_changed(world: int, battle: int)
signal survival_changed(hunger: float, thirst: float, fatigue: float)
signal gold_changed(amount: int)
signal character_loaded(character_id: String)


func _ready() -> void:
	pass


func is_logged_in() -> bool:
	return auth_token != ""


func get_divinity_title() -> String:
	return DIVINITY_TITLES[clampi(divinity_level, 0, 10)]


func set_world_energy(value: int) -> void:
	world_energy = clampi(value, 0, 100)
	energy_changed.emit(world_energy, battle_energy)


func set_battle_energy(value: int) -> void:
	battle_energy = clampi(value, 0, 10)
	energy_changed.emit(world_energy, battle_energy)


func set_survival(h: float, t: float, f: float) -> void:
	hunger  = clampf(h, 0.0, 100.0)
	thirst  = clampf(t, 0.0, 100.0)
	fatigue = clampf(f, 0.0, 100.0)
	survival_changed.emit(hunger, thirst, fatigue)


func is_exhausted() -> bool:
	return battle_energy <= 0


const GUEST_SAVE_PATH := "user://save_guest.cfg"

func save_guest() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("character", "name",           character_name)
	cfg.set_value("character", "appearance",      pending_appearance)
	cfg.set_value("character", "difficulty",      difficulty)
	cfg.set_value("character", "divinity_level",  divinity_level)
	cfg.set_value("character", "divinity_exp",    divinity_exp)
	cfg.set_value("character", "current_band",    current_band)
	cfg.set_value("character", "current_floor",   current_floor)
	cfg.set_value("character", "world_energy",    world_energy)
	cfg.set_value("character", "battle_energy",   battle_energy)
	cfg.set_value("character", "gold",            gold)
	cfg.set_value("character", "gems",            gems)
	cfg.set_value("character", "gacha_pity",      gacha_pity)
	cfg.set_value("character", "hunger",          hunger)
	cfg.set_value("character", "thirst",          thirst)
	cfg.set_value("character", "fatigue",         fatigue)
	cfg.save(GUEST_SAVE_PATH)


func load_guest() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(GUEST_SAVE_PATH) != OK:
		return false
	character_name      = cfg.get_value("character", "name",          "")
	if character_name.is_empty():
		return false
	pending_appearance  = cfg.get_value("character", "appearance",    {})
	difficulty          = cfg.get_value("character", "difficulty",    "normal")
	divinity_level      = cfg.get_value("character", "divinity_level", 0)
	divinity_exp        = cfg.get_value("character", "divinity_exp",   0)
	current_band        = cfg.get_value("character", "current_band",   1)
	current_floor       = cfg.get_value("character", "current_floor",  1)
	world_energy        = cfg.get_value("character", "world_energy",  100)
	battle_energy       = cfg.get_value("character", "battle_energy",  10)
	gold                = cfg.get_value("character", "gold",            0)
	gems                = cfg.get_value("character", "gems",            0)
	gacha_pity          = cfg.get_value("character", "gacha_pity",     0)
	hunger              = cfg.get_value("character", "hunger",        100.0)
	thirst              = cfg.get_value("character", "thirst",        100.0)
	fatigue             = cfg.get_value("character", "fatigue",       100.0)
	is_guest            = true
	return true


func delete_guest_save() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GUEST_SAVE_PATH))


func reset_session() -> void:
	auth_token = ""
	player_id = ""
	character_id = ""
	character_name = ""
	pending_appearance = {}
	is_guest = false
	divinity_level = 0
	divinity_exp = 0
	stats = {}
	world_energy = 100
	battle_energy = 10
	hunger = 100.0
	thirst = 100.0
	fatigue = 100.0
	gold = 0
	gems = 0
	gacha_pity = 0
	inventory = []
