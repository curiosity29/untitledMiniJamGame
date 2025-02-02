extends Node

var object_map: Dictionary# = \
#{
	#Vector2i(0,0): preload("res://Resource/Object/box.tres"),
	#Vector2i(1,0): preload("res://Resource/Object/player.tres")
#}

enum TileMapLayerID {GROUND_OBJECT = 1, WALL = 2, BACKGROUND = 4, OBJECT = 0}

@export var _all_objects = preload("res://Resource/ResourceGroup/object_resource_group.tres")
var all_objects: Array[ObjectResource]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_all_objects.load_all_into(all_objects)
	
	for object_resource: ObjectResource in all_objects:
		object_map[object_resource.coord_id] = object_resource
	pass # Replace with function body.

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
