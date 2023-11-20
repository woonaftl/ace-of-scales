extends TileMap


var x_max: int
var y_max: int


func _process(_delta: float) -> void:
	reset_cells()
	for card: Node in QueryCard.get_cards_in_state(Card.CardState.BOARD):
		for x: int in card.board_scale.x:
			for y: int in card.board_scale.y:
				set_occupied_cell(card.board_cell + Vector2i(x, y))
	for card: Node in QueryCard.get_cards_in_states([
		Card.CardState.HAND_SELECTED,
		Card.CardState.BOARD_SELECTED
	]):
		for cell: Vector2i in card.get_occupied_cells(card.target_cell):
			highlight_cell(cell)
		if card.blueprint.play_ability != null:
			for cell: Vector2i in card.blueprint.play_ability.get_affected_cells(card):
				if is_cell_within_playable_area(card.target_cell):
					if is_cell_within_playable_area(cell):
						set_cell(0, cell, 4, Vector2i.ZERO)


func reset_cells() -> void:
	for x: int in x_max + 1:
		for y: int in y_max + 1:
			set_vacant_cell(Vector2i(x, y))


func set_vacant_cell(cell: Vector2i) -> void:
	if is_cell_within_playable_area(cell):
		set_cell(0, cell, 0, Vector2i.ZERO)


func set_occupied_pos(global_pos: Vector2) -> void:
	set_occupied_cell(local_to_map(to_local(global_pos)))


func set_occupied_cell(cell: Vector2i) -> void:
	if is_cell_within_playable_area(cell):
		set_cell(0, cell, 3, Vector2i.ZERO)


func is_pos_vacant(global_pos: Vector2) -> bool:
	return is_cell_vacant(local_to_map(to_local(global_pos)))


func is_cell_vacant(cell: Vector2i) -> bool:
	return is_cell_within_playable_area(cell) and QueryCard.get_cards_in_state(Card.CardState.BOARD).all(
		func(card: Card):
			return not cell in card.get_occupied_cells()
	)


func get_pos_source_id(global_pos: Vector2) -> int:
	return get_cell_source_id(0, local_to_map(to_local(global_pos)))


func is_pos_within_playable_area(global_pos: Vector2) -> bool:
	return is_cell_within_playable_area(local_to_map(to_local(global_pos)))


func is_cell_within_playable_area(cell: Vector2) -> bool:
	return cell.x >= 0 and cell.x <= x_max and cell.y >= 0 and cell.y <= y_max


func highlight_pos(global_pos: Vector2) -> void:
	highlight_cell(local_to_map(to_local(global_pos)))


func highlight_cell(cell: Vector2i) -> void:
	if is_cell_within_playable_area(cell):
		if not is_cell_vacant(cell):
			set_cell(0, cell, 2, Vector2i.ZERO)
		elif get_cell_source_id(0, cell) == 0:
			set_cell(0, cell, 1, Vector2i.ZERO)


func map_to_global(cell: Vector2i) -> Vector2:
	return to_global(map_to_local(cell))


func global_to_map(p_global: Vector2) -> Vector2i:
	return local_to_map(to_local(p_global))


func get_position_from_board_cell_and_scale(
	board_cell: Vector2i, 
	board_scale: Vector2i
) -> Vector2:
	return to_global(map_to_local(board_cell)) + (board_scale - Vector2i.ONE) * 64.
