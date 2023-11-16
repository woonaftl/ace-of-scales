extends Node


func get_all_cards() -> Array[Card]:
	var result: Array[Card] = []
	for card: Node in get_tree().get_nodes_in_group("cards"):
		if card is Card and not card.is_queued_for_deletion():
			result.append(card)
	return result


func get_cards(player: Player, state: Card.CardState) -> Array[Card]:
	var result: Array[Card] = []
	for card: Node in get_tree().get_nodes_in_group("cards"):
		if card is Card and not card.is_queued_for_deletion():
			if card.player == player and card.state == state:
				result.append(card)
	return result


func get_cards_in_state(state: Card.CardState) -> Array[Card]:
	var result: Array[Card] = []
	for card: Node in get_tree().get_nodes_in_group("cards"):
		if card is Card and not card.is_queued_for_deletion() and card.state == state:
			result.append(card)
	return result


func get_cards_in_states(states: Array[Card.CardState]) -> Array[Card]:
	var result: Array[Card] = []
	for card: Node in get_tree().get_nodes_in_group("cards"):
		if card is Card and not card.is_queued_for_deletion() and states.has(card.state):
			result.append(card)
	return result


func get_cards_of_player(player: Player) -> Array[Card]:
	var result: Array[Card] = []
	for card: Node in get_tree().get_nodes_in_group("cards"):
		if card is Card and not card.is_queued_for_deletion() and card.player == player:
			result.append(card)
	return result


func get_cards_in_cells(cells: Array[Vector2i]) -> Array[Card]:
	var result: Array[Card] = []
	for cell: Vector2i in cells:
		for card: Card in get_cards_on_cell(cell):
			if not result.has(card) and not card.is_queued_for_deletion():
				result.append(card)
	return result


func get_cards_on_cell(cell: Vector2i) -> Array[Card]:
	var result: Array[Card] = []
	for card: Card in get_cards_in_state(Card.CardState.BOARD):
		for x: int in card.board_scale.x:
			for y: int in card.board_scale.y:
				if not result.has(card) and not card.is_queued_for_deletion():
					if cell == card.board_cell + Vector2i(x, y):
						result.append(card)
	return result


func get_cards_in_rectangle(top_left_cell: Vector2i, size: Vector2i) -> Array[Card]:
	return get_cards_in_cells(CellsHelpers.get_cells_inside_rectangle(top_left_cell, size))


func clear_selectiom() -> bool:
	var result: bool = false
	for card: Card in get_cards_in_state(Card.CardState.HAND_SELECTED):
		card.state = Card.CardState.HAND
		result = true
	for card: Card in get_cards_in_state(Card.CardState.BOARD_SELECTED):
		card.state = Card.CardState.BOARD
		result = true
	for card: Card in get_cards_in_state(Card.CardState.BOARD_SCALING):
		card.state = Card.CardState.BOARD
		result = true
	return result
