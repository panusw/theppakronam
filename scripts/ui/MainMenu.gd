extends Control
class_name MainMenu

const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
	_load_locale()
	_refresh_text()
	$CenterContainer/VBox/BtnCreateServer.pressed.connect(_on_create_server)
	$CenterContainer/VBox/BtnJoinServer.pressed.connect(_on_join_server)
	$CenterContainer/VBox/BtnPlay.pressed.connect(_on_play)
	$CenterContainer/VBox/BtnSettings.pressed.connect(_on_settings)
	$CenterContainer/VBox/BtnQuit.pressed.connect(get_tree().quit)


func _refresh_text() -> void:
	$CenterContainer/VBox/Title.text           = tr("MM_TITLE")
	$CenterContainer/VBox/Subtitle.text        = tr("MM_SUBTITLE")
	$CenterContainer/VBox/BtnCreateServer.text = tr("MM_BTN_CREATE_SERVER")
	$CenterContainer/VBox/BtnJoinServer.text   = tr("MM_BTN_JOIN_SERVER")
	$CenterContainer/VBox/BtnPlay.text         = tr("MM_BTN_GUEST")
	$CenterContainer/VBox/BtnSettings.text     = tr("MM_BTN_SETTINGS")
	$CenterContainer/VBox/BtnQuit.text         = tr("MM_BTN_QUIT")


func _load_locale() -> void:
	var cfg := ConfigFile.new()
	var locale := "th"
	if cfg.load(SETTINGS_PATH) == OK:
		locale = cfg.get_value("display", "locale", "th")
	TranslationServer.set_locale(locale)


func _on_create_server() -> void:
	pass  # TODO: เปิด server creation UI


func _on_join_server() -> void:
	pass  # TODO: เปิด room code / server browser


func _on_play() -> void:
	GameState.is_guest = true
	if GameState.load_guest():
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
