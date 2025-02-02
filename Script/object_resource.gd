class_name ObjectResource
extends Resource

@export var id: String
@export var layer_id: int = 3
@export var coord_id: Vector2i

@export var is_unfoldable: bool = true
@export var unfold_center_coord_id: Vector2i = Vector2i(2, 0)
@export var unfold_side_coord_id: Vector2i = Vector2i(1, 0)

@export var scene: PackedScene
