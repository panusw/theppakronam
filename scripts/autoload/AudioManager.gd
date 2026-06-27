extends Node
## Singleton — BGM and SFX management with pooled SFX players.

const SFX_POOL_SIZE: int = 8
const DEFAULT_BGM_VOLUME: float = 0.8
const DEFAULT_SFX_VOLUME: float = 1.0

var bgm_volume: float = DEFAULT_BGM_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME

var _bgm: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_bgm = AudioStreamPlayer.new()
	_bgm.bus = &"BGM"
	add_child(_bgm)

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_sfx_pool.append(p)


# --- BGM ---

func play_bgm(stream: AudioStream) -> void:
	if _bgm.stream == stream and _bgm.playing:
		return
	_bgm.stream = stream
	_bgm.volume_db = linear_to_db(bgm_volume)
	_bgm.play()


func stop_bgm() -> void:
	_bgm.stop()


func set_bgm_volume(linear: float) -> void:
	bgm_volume = clampf(linear, 0.0, 1.0)
	_bgm.volume_db = linear_to_db(bgm_volume)


# --- SFX ---

func play_sfx(stream: AudioStream) -> void:
	for p in _sfx_pool:
		if not p.playing:
			p.stream = stream
			p.volume_db = linear_to_db(sfx_volume)
			p.play()
			return
	# All slots busy — play on first slot (oldest)
	_sfx_pool[0].stream = stream
	_sfx_pool[0].play()


func set_sfx_volume(linear: float) -> void:
	sfx_volume = clampf(linear, 0.0, 1.0)
