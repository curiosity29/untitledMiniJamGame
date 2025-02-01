class_name LevelSelectButton
extends Button

@export var level_index: int = 1
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Level %d" % level_index



func _on_pressed() -> void:
	Event.level_selected.emit(level_index)
