class_name Player
extends MapObject


#@onready var sprite: Sprite2D = $Sprite

const GRID_SIZE: int = 64
enum LastAction {MOVE, FOLD}
var undo_funcs: Array[Callable]

func _ready() -> void:
	#current_pos = current_pos
	#round_pos()
	super()
	#current_tile = object_layer.local_to_map(global_position)

#region movement


#func _physics_process(delta: float) -> void:
	#if not is_moving: return
		#
	#if (global_position - sprite.global_position).length() < 1.:
		#is_moving = false
		#return
	#
	#sprite.global_position = sprite.global_position.move_toward(global_position, delta * SPEED)
func undo():
	if undo_funcs:
		SoundPlayer.play_sfx_by_id("undo")
		undo_funcs.pop_back().call()
	
func move(direction: Vector2, is_undo: bool = false) -> bool:
	current_tile = object_layer.local_to_map(global_position)
	var target_tile = current_tile + Vector2i(direction)
	print("move %s to %s " % [current_tile, target_tile])
	var object_tile_data: TileData = object_layer.get_cell_tile_data(target_tile)
	var wall_tile_data: TileData = wall_layer.get_cell_tile_data(target_tile)
	if wall_tile_data:
		return false
	var pushed: bool = false
	if object_tile_data:
		var object: MapObject = map.coord_to_object_map[target_tile]
		if not object.is_folded:
			return false
		if object_tile_data.get_custom_data("pushable"):
			print("player pushing from %s to %s" % [current_tile, target_tile])
			if not object.request_push(direction):
				return false
			print()
			SoundPlayer.play_sfx_by_id("push")
			if not is_undo:
				var undo_func = func():
					move(-direction)
					object.request_push(-direction)
				undo_funcs.append(undo_func)
		else:
			return false
	is_moving = true
	SoundPlayer.play_sfx_by_id("move")
	map.move_tile_object(current_tile, target_tile, self)
	global_position = object_layer.map_to_local(target_tile)
	#visual
	#look_at(global_position + Vector2(direction))
	sprite.global_position = object_layer.map_to_local(current_tile)
	current_tile = target_tile
	if not is_undo:
		if not pushed:
			var undo_func = func(): move(-direction, true)
			undo_funcs.append(undo_func)
	return true

func fold(direction: Vector2i, is_undo = false) -> void:
	# NOTE: fold object to the right
	var target_tile = current_tile + direction
	
	var object_tile_data: TileData = object_layer.get_cell_tile_data(target_tile)
	if object_tile_data:
		print("player at %s requesting unfold at %s ", [current_tile, target_tile])
		var object: MapObject = map.coord_to_object_map[target_tile]
		
		var success = object.request_fold()
		if success: 
			if object.is_folded:
				SoundPlayer.play_sfx_by_id("fold")
			else:
				SoundPlayer.play_sfx_by_id("unfold")
		print()
		if not is_undo:
			var undo_func = func(): object.request_fold()
			undo_funcs.append(undo_func)
			
		return

	var object_unfolded_tile_data: TileData = unfolded_object_layer.get_cell_tile_data(target_tile)
	if object_unfolded_tile_data:
		print("player at %s requesting fold at %s ", [current_tile, target_tile])
		var object = map.coord_to_foled_object_map[target_tile]
		object.request_fold()
		print()
		if not is_undo:
			var undo_func = func(): fold(direction, true)
			undo_funcs.append(undo_func)
	
func _input(event: InputEvent) -> void:
	#if is_moving: return
	#region movement
	var direction: Vector2
	if event.is_action_pressed("left"):
		direction = Vector2.LEFT
	if event.is_action_pressed("right"):
		direction = Vector2.RIGHT
	elif event.is_action_pressed("up"):
		direction = Vector2.UP
	elif event.is_action_pressed("down"):
		direction = Vector2.DOWN
	if direction: 
		current_direction = direction
		move(direction)
	#endregion
	
	var fold_direction: Vector2i
	if event.is_action_pressed("fold_left"):
		fold_direction = Vector2.LEFT
	if event.is_action_pressed("fold_right"):
		fold_direction = Vector2.RIGHT
	elif event.is_action_pressed("fold_up"):
		fold_direction = Vector2.UP
	elif event.is_action_pressed("fold_down"):
		fold_direction = Vector2.DOWN
	
	if fold_direction: 
		fold(fold_direction)
	
	if event.is_action_pressed("undo"):
		undo()
	
#endregion
