extends PlayAbility


const DAMAGE: int = 2


func use(card: Card) -> void:
	super(card)
	for damaged_card in get_damaged_cards(card):
		var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
		card.get_tree().current_scene.add_child(projectile)
		projectile.global_position = card.global_position
		projectile.attacker = card
		projectile.target = damaged_card
		projectile.damage = DAMAGE
		projectile.target_position = damaged_card.global_position
		projectile.z_index = 128
	while len(card.get_tree().get_nodes_in_group("projectile")):
		await card.get_tree().create_timer(0.01).timeout


func get_affected_cells(card: Card) -> Array[Vector2i]:
	if card.state == Card.CardState.HAND_SELECTED or card.state == Card.CardState.BOARD_SELECTED:
		var result: Array[Vector2i] = card.get_occupied_cells(card.target_cell)
		result.append_array(CellsHelpers.get_cells_adjacent_to_rectangle(
			card.target_cell,
			card.board_scale
		))
		return result
	else:
		var result: Array[Vector2i] = card.get_occupied_cells(card.board_cell)
		result.append_array(CellsHelpers.get_cells_adjacent_to_rectangle(
			card.board_cell,
			card.board_scale
		))
		return result


func get_damaged_cards(card: Card) -> Array[Card]:
	var result: Array[Card] = [card]
	result.append_array(QueryCard.get_cards_in_cells(get_affected_cells(card)).filter(
		func(affected_card: Card):
			return affected_card.player != card.player
	))
	return result
