extends Control
@onready var main_scene_container: Control = $MainSceneContainer

@export var LEVEL_SELECT: PackedScene
@export var SETTING_SCENE: PackedScene
@export var MENU_SCENE: PackedScene
@export var level_map: Dictionary[int, PackedScene]
@onready var setting_sub_viewport: SubViewport = $SettingViewportContainer/SettingSubViewport
@onready var setting_viewport_container: SubViewportContainer = $SettingViewportContainer


var main_scene: Node:
	get:
		return main_scene_container.get_child(0)
var current_packed_scene: PackedScene
func change_scene(packed_scene: PackedScene, do_close_settting: bool = true):
	if do_close_settting: close_setting()
	#get_tree().paused = true
	#print("paused")
	main_scene.queue_free()
	var new_scene = packed_scene.instantiate()
	main_scene_container.add_child(new_scene)
	current_packed_scene = packed_scene
	
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	change_scene(MENU_SCENE)
	Event.level_selected.connect(on_level_selected)
	Event.request_exit_to_menu.connect(exit_to_menu)
	Event.request_open_setting.connect(open_setting)
	Event.request_close_setting.connect(close_setting)
	Event.request_open_level_select.connect(change_scene.bind(LEVEL_SELECT))
	
	SoundPlayer.play_music(SoundPlayer.main_music)


func on_level_selected(level_index: int = 1):
	if level_index in level_map:
		change_scene(level_map[level_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset") and main_scene is Map:
		change_scene(current_packed_scene)
		SoundPlayer.play_sfx_by_id("reset")
	elif event.is_action_pressed("exit"):
		if setting_viewport_container.visible:
			close_setting()
		else:
			open_setting()

			
func close_setting():
	main_scene_container.show()
	setting_viewport_container.hide()
func open_setting():
	setting_viewport_container.show()
	main_scene_container.hide()
func exit_to_menu():
	change_scene(MENU_SCENE)
