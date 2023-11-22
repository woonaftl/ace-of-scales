extends PlayAbility


const DAMAGE: int = 2


func use(card: Card) -> void:
	super(card)
	for damaged_card in get_damaged_cards(card, card.board_cell):
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


func get_affected_cells(card: Card, cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = card.get_occupied_cells(card.target_cell)
	result.append_array(CellsHelpers.get_cells_adjacent_to_rectangle(
		cell,
		card.board_scale
	))
	return result


func get_damaged_cards(card: Card, cell: Vector2i) -> Array[Card]:
	var result: Array[Card] = [card]
	result.append_array(get_damaged_opponent_cards(card, cell))
	return result


func get_damaged_opponent_cards(card: Card, cell: Vector2i) -> Array[Card]:
	return QueryCard.get_cards_in_cells(get_affected_cells(card, cell)).filter(
		func(damaged_card: Card):
			return damaged_card.player != card.player
	)


func get_value(card: Card, cell: Vector2i) -> int:
	return len(get_damaged_opponent_cards(card, cell)) * DAMAGE
