extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_setting_button_pressed() -> void:
	Event.request_open_setting.emit()


func _on_level_select_button_pressed() -> void:
	Event.request_open_level_select.emit()
