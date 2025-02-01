extends Control

@onready var sprite: Sprite2D = $Sprite

var object_layer: TileMapLayer:
	get: return InstanceHelper.map.object_layer#: TileMapLayer = %ObjectLayer
var wall_layer: TileMapLayer:
	get: return InstanceHelper.map.wall_layer
var map: Map = InstanceHelper.map

var is_moving: bool = false
var SPEED: float = 350
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func request_push(direction: Vector2i) -> bool:
	if is_moving: return false
	var current_tile = object_layer.local_to_map(global_position)
	var target_tile = current_tile + Vector2i(direction)
	
	
	
	var object_tile_data: TileData = object_layer.get_cell_tile_data(target_tile)
	var wall_tile_data: TileData = wall_layer.get_cell_tile_data(target_tile)
	if wall_tile_data:
		return false
	
	if object_tile_data:
		if not object_tile_data.get_custom_data("pushable"):
			var object = map.coord_to_object_map[target_tile]
			if not object.request_push(direction):
				return false
		else:
			return false

	is_moving = true
	map.move_tile_object(current_tile, target_tile, self)
	
	global_position = object_layer.map_to_local(target_tile)
	#visual
	sprite.global_position = object_layer.map_to_local(current_tile)
	current_tile = target_tile
	
	return true

func _physics_process(delta: float) -> void:
	if not is_moving: return
		
	if (global_position - sprite.global_position).length() < 1.:
		is_moving = false
		return
	
	sprite.global_position = sprite.global_position.move_toward(global_position, delta * SPEED)
