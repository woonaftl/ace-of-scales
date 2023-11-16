extends Object
class_name CellsHelpers


static func get_cells_inside_rectangle(
	top_left_cell: Vector2i,
	size: Vector2i
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x: int in size.x:
		for y: int in size.y:
			result.append(top_left_cell + Vector2i(x, y))
	return result


static func get_cells_near_rectangle(
	top_left_cell: Vector2i,
	size: Vector2i
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x: int in range(-1, size.x + 1):
		result.append(top_left_cell + Vector2i(x, -1))
		result.append(top_left_cell + Vector2i(x, size.y))
	for y: int in size.y:
		result.append(top_left_cell + Vector2i(-1, y))
		result.append(top_left_cell + Vector2i(size.x, y))
	return result


static func get_cells_diagonal_to_rectangle(
	top_left_cell: Vector2i,
	size: Vector2i
) -> Array[Vector2i]:
	return [
		top_left_cell - Vector2i.ONE,
		Vector2i(
			top_left_cell.x + size.x,
			top_left_cell.y - 1
		),
		Vector2i(
			top_left_cell.x - 1,
			top_left_cell.y + size.y
		),
		top_left_cell + size,
	]


static func get_cells_adjacent_to_rectangle(
	top_left_cell: Vector2i,
	size: Vector2i
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x: int in size.x:
		result.append(top_left_cell + Vector2i(x, -1))
		result.append(top_left_cell + Vector2i(x, size.y))
	for y: int in size.y:
		result.append(top_left_cell + Vector2i(-1, y))
		result.append(top_left_cell + Vector2i(size.x, y))
	return result
