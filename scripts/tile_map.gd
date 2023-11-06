extends TileMap


var x_max: int = 2
var y_max: int = 2


func _process(_delta: float) -> void:
	reset_cells()
	for card: Node in get_tree().get_nodes_in_group("card_on_board"):
		set_occupied_pos(card.global_position)
	for card: Node in get_tree().get_nodes_in_group("card_selected"):
		highlight_pos(card.global_position)


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
	return is_cell_within_playable_area(cell) and [0, 1].has(get_cell_source_id(0, cell))


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


func global_to_map(p_global: Vector2) -> Vector2i:
	return local_to_map(to_local(p_global))
