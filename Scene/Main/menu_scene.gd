extends Control
var num = 0

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


func _on_button_pressed() -> void:
	get_tree().quit()


func _on_button_2_pressed() -> void:
	num += 1
	if num == 3:
		%AudioStreamPlayer2D.play()

	
