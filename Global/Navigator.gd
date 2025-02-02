extends Control
@onready var main_scene_container: Control = $MainSceneContainer

@export var LEVEL_SELECT: PackedScene
@export var level_map: Dictionary[int, PackedScene]

var main_scene: Node:
	get:
		return main_scene_container.get_child(0)
var current_packed_scene: PackedScene
func change_scene(packed_scene: PackedScene):
	#get_tree().paused = true
	#print("paused")
	main_scene.queue_free()
	var new_scene = packed_scene.instantiate()
	main_scene_container.add_child(new_scene)
	current_packed_scene = packed_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_scene(LEVEL_SELECT)
	Event.level_selected.connect(on_level_selected)

func on_level_selected(level_index: int = 1):
	if level_index in level_map:
		change_scene(level_map[level_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		change_scene(current_packed_scene)
