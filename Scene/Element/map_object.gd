class_name MapObject
extends Control

@onready var sprite: Sprite2D = %Sprite

@export var unfold_relative_coords: Array[Vector2i] = [
						Vector2i(0, -1), 
										Vector2i(1, 0),
	Vector2i(-1, 1),		Vector2i(0, 1),
						Vector2i(0, 2),
]
@export var is_folded: bool = true:
	set(value):
		is_folded = value
		if is_folded: modulate.a = 1.
		else: modulate.a = 0.

var object_layer: TileMapLayer:
	get: return InstanceHelper.map.object_layer#: TileMapLayer = %ObjectLayer
var wall_layer: TileMapLayer:
	get: return InstanceHelper.map.wall_layer
var ground_object_layer: TileMapLayer:
	get: return InstanceHelper.map.ground_object_layer
var unfolded_object_layer: TileMapLayer:
	get: return InstanceHelper.map.unfolded_object_layer

var map: Map = InstanceHelper.map
var current_direction: Vector2i = Vector2i.RIGHT
var object_resource: ObjectResource

var is_moving: bool = false
var SPEED: float = 550
var current_tile: Vector2i = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func update_tile():
	current_tile = object_layer.local_to_map(global_position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func request_push(direction: Vector2i, force: bool = false) -> bool:
	if is_moving: return false
	current_tile = object_layer.local_to_map(global_position)
	var target_tile = current_tile + Vector2i(direction)
	
	
	if not force:
		var object_tile_data: TileData = object_layer.get_cell_tile_data(target_tile)
		var wall_tile_data: TileData = wall_layer.get_cell_tile_data(target_tile)
		if wall_tile_data:
			return false
		
		if object_tile_data:
			var object: MapObject = map.coord_to_object_map[target_tile]
			if not object.is_folded:
				return false
			### NOTE: pushable here is able to push along with this object (at the same time)
			#if not object_tile_data.get_custom_data("pushable"):
				#if not object.request_push(direction):
					#return false
			else:
				return false

	is_moving = true
	map.move_tile_object(current_tile, target_tile, self)
	
	global_position = object_layer.map_to_local(target_tile)
	#visual
	sprite.global_position = object_layer.map_to_local(current_tile)
	print("		object pushed from %s to %s" % [current_tile, target_tile])
	current_tile = target_tile
	return true

func check_tile_empty(tile_coord: Vector2i) -> bool:
	## NOTE: check if no wall, no object, and no ground object
	var object_tile_data: TileData = object_layer.get_cell_tile_data(tile_coord)
	var wall_tile_data: TileData = wall_layer.get_cell_tile_data(tile_coord)
	var ground_object_tile_data: TileData = ground_object_layer.get_cell_tile_data(tile_coord)
	if object_tile_data or wall_tile_data or ground_object_tile_data:
		return false
	return true
func check_non_object_tile_empty(tile_coord: Vector2i) -> bool:
	## NOTE: check if no wall, no object, and no ground object
	var wall_tile_data: TileData = wall_layer.get_cell_tile_data(tile_coord)
	var ground_object_tile_data: TileData = ground_object_layer.get_cell_tile_data(tile_coord)
	if wall_tile_data or ground_object_tile_data:
		return false
	return true

func request_fold(force: bool = false) -> bool:
	var is_success: bool = false
	if is_folded:
		is_success = unfold_self(force)
	else:
		is_success = fold_self(force)
	if is_success:
		Event.object_fold_change.emit(self, is_folded)
	
	return is_success
	
func fold_self(force: bool = false) -> bool:
	for relative_tile_coord in unfold_relative_coords:
		var tile_coord = relative_tile_coord + current_tile
		ground_object_layer.set_cell(tile_coord)
	ground_object_layer.set_cell(current_tile)
	## move object from unfolded to object layer
	object_layer.set_cell(current_tile, unfolded_object_layer.get_cell_source_id(current_tile), object_resource.coord_id)
	unfolded_object_layer.set_cell(current_tile)
	
	is_folded = true
	print("				folded at %s" % current_tile)
	return true
func unfold_self(force: bool = false) -> bool:
	## check if all unfold tile is empty, then unfold if satisfy
	print("		attempting unfold at: ", current_tile)
	if not force:
		if not check_non_object_tile_empty(current_tile):
			print("				failed at relative tile: ", current_tile)
			return false
		for relative_tile_coord in unfold_relative_coords:
			var tile_coord = relative_tile_coord + current_tile
			if not check_tile_empty(tile_coord):
				print("				failed at relative tile: ", relative_tile_coord)
				return false
	for relative_tile_coord in unfold_relative_coords:
		var tile_coord = relative_tile_coord + current_tile
		ground_object_layer.set_cell(tile_coord, Database.TileMapLayerID.GROUND_OBJECT, object_resource.unfold_side_coord_id)
	ground_object_layer.set_cell(current_tile, Database.TileMapLayerID.GROUND_OBJECT, object_resource.unfold_center_coord_id)
	
	## move object to unfolded layer
	unfolded_object_layer.set_cell(current_tile, object_layer.get_cell_source_id(current_tile), object_resource.coord_id)
	object_layer.set_cell(current_tile)
	
	
	is_folded = false
	print("				unfold successful")
	return true
	
func _physics_process(delta: float) -> void:
	if not is_moving: return
		
	if (global_position - sprite.global_position).length() < 1.:
		is_moving = false
		return
	
	sprite.global_position = sprite.global_position.move_toward(global_position, delta * SPEED)
