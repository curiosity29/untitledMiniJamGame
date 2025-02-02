class_name Map
extends Control

@onready var wall_layer: TileMapLayer = %WallLayer
@onready var object_layer: TileMapLayer = %ObjectLayer
@onready var background_layer: TileMapLayer = %BackgroundLayer
@onready var ground_object_layer: TileMapLayer = %GroundObjectLayer
@onready var ground_requirement_layer: TileMapLayer = %GroundRequirementLayer
@export var level_index: int = 1
@onready var score_label: Label = $ScoreLabel
@onready var next_level_button: Button = %NextLevelButton
@onready var unfolded_object_layer: TileMapLayer = %UnfoldedObjectLayer



var coord_to_object_map: Dictionary
var coord_to_foled_object_map: Dictionary
var score_count: int = 0:
	set(value):
		score_count = value
		score_label.text = "Number of item in place: %d" % score_count

func create_objects():
	
	for cell_pos in object_layer.get_used_cells():
		#print(cell)
		var object_id = object_layer.get_cell_atlas_coords(cell_pos)
		var object_scene = add_object_by_id(cell_pos, object_id)
		coord_to_object_map[cell_pos] = object_scene
	object_layer.hide()
	unfolded_object_layer.hide()
	
# Called when the node enters the scene tree for the first time.
func move_tile_object(current_tile: Vector2i, target_tile: Vector2i, object: Node):
	object_layer.set_cell(target_tile, object_layer.get_cell_source_id(current_tile), object_layer.get_cell_atlas_coords(current_tile))
	object_layer.set_cell(current_tile)
	coord_to_object_map.erase(current_tile)
	coord_to_object_map[target_tile] = object
	#update_count_object_on_correct_ground(current_tile, false)
	#update_count_object_on_correct_ground(target_tile, true)
	 
func on_object_fold_change(map_object: MapObject, is_folding: bool = true):
	var current_tile = map_object.current_tile
	var unfold_relative_coords = map_object.unfold_relative_coords
	update_count_ground_object_on_correct_ground(current_tile, !is_folding)
	for relative_tile_coord in unfold_relative_coords:
		var tile_coord = relative_tile_coord + current_tile
		update_count_ground_object_on_correct_ground(tile_coord, !is_folding)
		
	# move from object layer to folded layer, or vise versa
	if is_folding:
		coord_to_object_map[map_object.current_tile] = coord_to_foled_object_map[map_object.current_tile]
		coord_to_foled_object_map.erase(map_object.current_tile)
	else:
		coord_to_foled_object_map[map_object.current_tile] = coord_to_object_map[map_object.current_tile]
		coord_to_object_map.erase(map_object.current_tile)
		
func update_count_ground_object_on_correct_ground(object_cell_pos: Vector2i, is_add: bool = true):
	if object_cell_pos in ground_requirement_layer.get_used_cells():
		if is_add:
			score_count += 1
		else:
			score_count -= 1
			
	if score_count >= required_score_count:
		next_level_button.show()
		SoundPlayer.play_sfx_by_id("win")

var required_score_count: int = 0
func _ready() -> void:
	score_label.hide()
	next_level_button.hide()
	InstanceHelper.map = self
	create_objects()
	Event.object_fold_change.connect(on_object_fold_change)
	required_score_count = ground_requirement_layer.get_used_cells().size()
func add_object_by_id(pos: Vector2i, id: Vector2i):
	var object_resource: ObjectResource = Database.object_map[id]
	var object_scene: MapObject = object_resource.scene.instantiate()
	object_scene.object_resource = object_resource
	add_child(object_scene)
	object_scene.position = object_layer.map_to_local(pos)
	object_scene.update_tile()
	#object_scene.size = Vector2(64, 64)
	#print("creating with ", object_scene.position)
	return object_scene

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_next_level_button_pressed() -> void:
	Event.level_selected.emit(level_index + 1)
	
