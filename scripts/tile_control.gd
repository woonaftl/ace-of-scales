extends Control


signal user_input_failed(message: String)


var player: Player
var is_mouse_inside: bool = false


@onready var tile_map: TileMap = $TileMap as TileMap


func _ready() -> void:
	user_input_failed.connect(EventBus._on_user_input_failed)


func _process(_delta):
	var tile_size = tile_map.tile_set.tile_size
	var used_rect = tile_map.get_used_rect().size
	custom_minimum_size = Vector2(tile_size.x * used_rect.x, tile_size.y * used_rect.y)
	for card in get_tree().get_nodes_in_group("card_on_board"):
		card.target_position = to_global(tile_map.map_to_local(card.board_position))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_mouse_inside:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var selected_card = get_tree().get_first_node_in_group("card_selected")
		if is_instance_valid(selected_card):
			get_viewport().set_input_as_handled()
			if can_place_card_here():
				if player.energy >= selected_card.blueprint.play_cost:
					selected_card.remove_from_group("card_selected")
					selected_card.add_to_group("card_on_board")
					selected_card.board_position = tile_map.global_to_map(mouse_pos)
					player.energy -= selected_card.blueprint.play_cost
				else:
					user_input_failed.emit("Not enough energy")
					selected_card.remove_from_group("card_selected")
					selected_card.add_to_group("card_in_hand")
			else:
				user_input_failed.emit("This place is already occupied")
				selected_card.remove_from_group("card_selected")
				selected_card.add_to_group("card_in_hand")


func can_place_card_here() -> bool:
	return tile_map.is_pos_vacant(get_global_mouse_position())


func snap_to_tiles_local(p_local: Vector2) -> Vector2:
	return tile_map.map_to_local(tile_map.local_to_map(p_local))


func snap_to_tiles_global(p_global: Vector2) -> Vector2:
	return to_global(snap_to_tiles_local(to_local(p_global)))


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local


func _on_mouse_entered():
	is_mouse_inside = true


func _on_mouse_exited():
	is_mouse_inside = false
