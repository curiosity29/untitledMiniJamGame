extends Control

@onready var grid_container: GridContainer = $Control/GridContainer

@export var level_count: int = 10
@export var level_button_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_level_button()
	pass # Replace with function body.

func create_level_button():
	for level_index in range(1, level_count + 1):
		var level_button = level_button_scene.instantiate()
		level_button.level_index = level_index
		grid_container.add_child(level_button)
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
