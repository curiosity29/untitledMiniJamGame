class_name SettingMenu
extends Control


@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sfx_slider.value = State.sfx_volume
	music_slider.value = State.music_volume
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_music_slider_value_changed(value: float) -> void:
	State.music_volume = value


func _on_sfx_slider_value_changed(value: float) -> void:
	State.music_volume = value


func _on_close_button_pressed() -> void:
	Event.request_close_setting.emit()

func _on_back_to_menu_button_pressed() -> void:
	Event.request_exit_to_menu.emit()
