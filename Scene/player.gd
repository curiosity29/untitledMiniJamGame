extends CharacterBody2D

var object_layer: TileMapLayer:
	get: return InstanceHelper.map.object_layer#: TileMapLayer = %ObjectLayer
var wall_layer: TileMapLayer:
	get: return InstanceHelper.map.wall_layer
var map: Map:
	get: return InstanceHelper.map
@onready var sprite: Sprite2D = $Sprite

const GRID_SIZE: int = 64

var is_moving: bool = false
var SPEED: float = 350

func _ready() -> void:
	#current_pos = current_pos
	#round_pos()
	object_layer = InstanceHelper.map.object_layer
	pass

#region movement

var current_tile: Vector2i = Vector2i.ZERO

func _physics_process(delta: float) -> void:
	if not is_moving: return
		
	if (global_position - sprite.global_position).length() < 1.:
		is_moving = false
		return
	
	sprite.global_position = sprite.global_position.move_toward(global_position, delta * SPEED)

func move(direction: Vector2) -> bool:
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
	
	return true
func _input(event: InputEvent) -> void:
	var direction: Vector2
	if event.is_action_pressed("left"):
		direction = Vector2.LEFT
	if event.is_action_pressed("right"):
		direction = Vector2.RIGHT
	elif event.is_action_pressed("up"):
		direction = Vector2.UP
	elif event.is_action_pressed("down"):
		direction = Vector2.DOWN
	if direction: move(direction)
#endregion
