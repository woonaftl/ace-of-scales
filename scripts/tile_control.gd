extends Control


signal user_input_failed(message: String)


@onready var tile_map: TileMap = %TileMap as TileMap


func _ready() -> void:
	user_input_failed.connect(EventBus._on_user_input_failed)


func _process(_delta):
	var tile_size = tile_map.tile_set.tile_size
	var used_rect = tile_map.get_used_rect().size
	custom_minimum_size = Vector2(tile_size.x * used_rect.x, tile_size.y * used_rect.y)
	for card in get_tree().get_nodes_in_group("card_on_board"):
		card.target_position = tile_map.get_position_from_board_position_and_scale(card.board_position, card.board_scale)


func cell_to_global(cell: Vector2i):
	return to_global(tile_map.map_to_local(cell))


func snap_to_tiles_local(p_local: Vector2) -> Vector2:
	return tile_map.map_to_local(tile_map.local_to_map(p_local))


func snap_to_tiles_global(p_global: Vector2) -> Vector2:
	return to_global(snap_to_tiles_local(to_local(p_global)))


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local
