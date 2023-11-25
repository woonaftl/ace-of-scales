extends PlayAbility


func use(card: Card) -> void:
	super(card)
	for healed_card in get_healed_cards(card, card.board_cell):
		if healed_card.blueprint.play_ability != null:
			if healed_card.blueprint.play_ability != load("res://abilities/repeat_adjacent.tres"):
				await healed_card.blueprint.play_ability.use(healed_card)


func get_affected_cells(card: Card, cell: Vector2i) -> Array[Vector2i]:
	return CellsHelpers.get_cells_adjacent_to_rectangle(
		cell,
		card.board_scale
	)


func get_healed_cards(card: Card, cell: Vector2i) -> Array[Card]:
	return QueryCard.get_cards_in_cells(get_affected_cells(card, cell)).filter(
		func(affected_card: Card):
			return affected_card.player == card.player
	)


func get_value(card: Card, cell: Vector2i) -> int:
	return len(get_healed_cards(card, cell))
