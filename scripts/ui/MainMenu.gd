extends Control
class_name MainMenu

enum Mode { LOGIN, REGISTER }

const SETTINGS_PATH := "user://settings.cfg"

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var _input_email:   LineEdit = $CenterContainer/VBox/FormContainer/InputEmail
@onready var _input_password:LineEdit = $CenterContainer/VBox/FormContainer/InputPassword
@onready var _input_confirm: LineEdit = $CenterContainer/VBox/FormContainer/InputConfirm
@onready var _btn_submit:    Button   = $CenterContainer/VBox/FormContainer/BtnSubmit
@onready var _lbl_status:    Label    = $CenterContainer/VBox/LblStatus
@onready var _btn_login_tab: Button   = $CenterContainer/VBox/ModeToggle/BtnLoginTab
@onready var _btn_reg_tab:   Button   = $CenterContainer/VBox/ModeToggle/BtnRegisterTab
@onready var _btn_th:        Button   = $CenterContainer/VBox/LangRow/BtnTH
@onready var _btn_en:        Button   = $CenterContainer/VBox/LangRow/BtnEN

var _mode: Mode = Mode.LOGIN

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_load_locale()
	_refresh_text()
	_switch_mode(Mode.LOGIN)
	_btn_login_tab.pressed.connect(func(): _switch_mode(Mode.LOGIN))
	_btn_reg_tab.pressed.connect(func(): _switch_mode(Mode.REGISTER))
	_btn_submit.pressed.connect(_on_submit)
	$CenterContainer/VBox/BtnGuest.pressed.connect(_on_guest)
	$CenterContainer/VBox/BtnQuit.pressed.connect(get_tree().quit)
	_btn_th.pressed.connect(func(): _set_locale("th"))
	_btn_en.pressed.connect(func(): _set_locale("en"))


func _refresh_text() -> void:
	$CenterContainer/VBox/Title.text    = tr("MM_TITLE")
	$CenterContainer/VBox/Subtitle.text = tr("MM_SUBTITLE")
	_input_email.placeholder_text       = tr("MM_PLACEHOLDER_EMAIL")
	_input_password.placeholder_text    = tr("MM_PLACEHOLDER_PASSWORD")
	_input_confirm.placeholder_text     = tr("MM_PLACEHOLDER_CONFIRM")
	$CenterContainer/VBox/BtnGuest.text = tr("MM_BTN_GUEST")
	$CenterContainer/VBox/BtnQuit.text  = tr("MM_BTN_QUIT")
	_btn_login_tab.text                 = tr("MM_TAB_LOGIN")
	_btn_reg_tab.text                   = tr("MM_TAB_REGISTER")
	_update_lang_buttons()


func _switch_mode(mode: Mode) -> void:
	_mode = mode
	_input_confirm.visible  = (mode == Mode.REGISTER)
	_btn_submit.text        = tr("MM_TAB_REGISTER") if mode == Mode.REGISTER else tr("MM_TAB_LOGIN")
	_btn_login_tab.button_pressed = (mode == Mode.LOGIN)
	_btn_reg_tab.button_pressed   = (mode == Mode.REGISTER)
	_lbl_status.text = ""

# ---------------------------------------------------------------------------
# Language
# ---------------------------------------------------------------------------

func _load_locale() -> void:
	var cfg := ConfigFile.new()
	var locale := "th"
	if cfg.load(SETTINGS_PATH) == OK:
		locale = cfg.get_value("display", "locale", "th")
	TranslationServer.set_locale(locale)


func _set_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("display", "locale", locale)
	cfg.save(SETTINGS_PATH)
	_refresh_text()
	_switch_mode(_mode)


func _update_lang_buttons() -> void:
	var current := TranslationServer.get_locale()
	_btn_th.button_pressed = current.begins_with("th")
	_btn_en.button_pressed = current.begins_with("en")

# ---------------------------------------------------------------------------
# Submit
# ---------------------------------------------------------------------------

func _on_submit() -> void:
	var email := _input_email.text.strip_edges()
	var pw    := _input_password.text

	if email.is_empty() or not "@" in email:
		_set_status(tr("MM_ERR_EMAIL"))
		return
	if pw.length() < 6:
		_set_status(tr("MM_ERR_PASSWORD_SHORT"))
		return
	if _mode == Mode.REGISTER and _input_confirm.text != pw:
		_set_status(tr("MM_ERR_PASSWORD_MISMATCH"))
		return

	_set_status(tr("MM_STATUS_LOADING"))
	_btn_submit.disabled = true

	SupabaseClient.request_completed.connect(_on_auth_done, CONNECT_ONE_SHOT)
	SupabaseClient.request_failed.connect(_on_auth_failed, CONNECT_ONE_SHOT)

	if _mode == Mode.REGISTER:
		SupabaseClient.auth_signup(email, pw)
	else:
		SupabaseClient.auth_login(email, pw)

# ---------------------------------------------------------------------------
# Auth response handlers
# ---------------------------------------------------------------------------

func _on_auth_done(data: Variant) -> void:
	_btn_submit.disabled = false

	if not data is Dictionary:
		_set_status(tr("MM_ERR_REQUEST") % [0, "invalid response"])
		return

	if not data.has("access_token"):
		_set_status(tr("MM_INFO_CONFIRM_EMAIL"))
		return

	GameState.auth_token = data["access_token"]
	GameState.player_id  = data.get("user", {}).get("id", "")

	if _mode == Mode.REGISTER:
		get_tree().change_scene_to_file("res://scenes/character_creator.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")


func _on_auth_failed(code: int, message: String) -> void:
	_btn_submit.disabled = false
	var parsed := JSON.new()
	if parsed.parse(message) == OK and parsed.get_data() is Dictionary:
		var d: Dictionary = parsed.get_data()
		message = d.get("error_description", d.get("msg", d.get("message", message)))
	_set_status(tr("MM_ERR_REQUEST") % [code, message])

# ---------------------------------------------------------------------------
# Guest
# ---------------------------------------------------------------------------

func _on_guest() -> void:
	GameState.is_guest = true
	if GameState.load_guest():
		# มี save อยู่แล้ว — ไปหน้าเลือกตัวละคร เพื่อให้ลบ/สร้างใหม่ได้
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	else:
		# ยังไม่มี save — สร้างตัวละครใหม่
		get_tree().change_scene_to_file("res://scenes/character_creator.tscn")

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _set_status(text: String) -> void:
	_lbl_status.text = text
