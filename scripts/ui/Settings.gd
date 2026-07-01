extends Control
class_name Settings

const SETTINGS_PATH := "user://settings.cfg"

@onready var _btn_th: Button = $CenterContainer/VBox/LangRow/BtnTH
@onready var _btn_en: Button = $CenterContainer/VBox/LangRow/BtnEN

func _ready() -> void:
	_refresh_text()
	_btn_th.pressed.connect(func(): _set_locale("th"))
	_btn_en.pressed.connect(func(): _set_locale("en"))
	$CenterContainer/VBox/BtnBack.pressed.connect(_on_back)


func _refresh_text() -> void:
	$CenterContainer/VBox/Title.text    = tr("SET_TITLE")
	$CenterContainer/VBox/LangLabel.text = tr("SET_LANG_LABEL")
	$CenterContainer/VBox/BtnBack.text  = tr("SET_BTN_BACK")
	_update_lang_buttons()


func _set_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("display", "locale", locale)
	cfg.save(SETTINGS_PATH)
	_refresh_text()


func _update_lang_buttons() -> void:
	var current := TranslationServer.get_locale()
	_btn_th.button_pressed = current.begins_with("th")
	_btn_en.button_pressed = current.begins_with("en")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
