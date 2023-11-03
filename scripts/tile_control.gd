extends Control


@onready var tile_map: TileMap = $TileMap as TileMap


func _process(_delta):
	var tile_size = tile_map.tile_set.tile_size
	var used_rect = tile_map.get_used_rect().size
	custom_minimum_size = Vector2(tile_size.x * used_rect.x, tile_size.y * used_rect.y)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var selected_card = get_tree().get_first_node_in_group("card_selected")
		if is_instance_valid(selected_card):
			get_viewport().set_input_as_handled()
			if tile_map.is_pos_vacant(mouse_pos):
				selected_card.remove_from_group("card_selected")
				selected_card.add_to_group("card_on_board")
				selected_card.target_position = snap_to_tiles_global(mouse_pos)
			else:
				selected_card.remove_from_group("card_selected")
				selected_card.add_to_group("card_in_hand")


func snap_to_tiles_local(p_local: Vector2) -> Vector2:
	return tile_map.map_to_local(tile_map.local_to_map(p_local))


func snap_to_tiles_global(p_global: Vector2) -> Vector2:
	return to_global(snap_to_tiles_local(to_local(p_global)))


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local
