extends PlayAbility


const DAMAGE: int = 1
const HEAL: int = -1


func use(card: Card) -> void:
	super(card)
	for damaged_card in get_damaged_cards(card, card.board_cell):
		var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
		card.get_tree().current_scene.add_child(projectile)
		projectile.global_position = card.global_position
		projectile.attacker = card
		projectile.target = damaged_card
		projectile.damage = DAMAGE
		projectile.z_index = 128
	for healed_card in get_healed_cards(card, card.board_cell):
		var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
		card.get_tree().current_scene.add_child(projectile)
		projectile.global_position = card.global_position
		projectile.attacker = card
		projectile.target = healed_card
		projectile.damage = HEAL
		projectile.target_position = healed_card.global_position
		projectile.z_index = 128
	while len(card.get_tree().get_nodes_in_group("projectile")):
		await card.get_tree().create_timer(0.01).timeout


func get_affected_cells(card: Card, cell: Vector2i) -> Array[Vector2i]:
	return CellsHelpers.get_cells_diagonal_to_rectangle(
		cell,
		card.board_scale
	)


func get_damaged_cards(card: Card, cell: Vector2i) -> Array[Card]:
	return QueryCard.get_cards_in_cells(get_affected_cells(card, cell)).filter(
		func(affected_card: Card):
			return affected_card.player != card.player
	)


func get_healed_cards(card: Card, cell: Vector2i) -> Array[Card]:
	return QueryCard.get_cards_in_cells(get_affected_cells(card, cell)).filter(
		func(affected_card: Card):
			return affected_card.player == card.player
	)


func get_value(card: Card, cell: Vector2i) -> int:
	return len(get_damaged_cards(card, cell)) * DAMAGE + len(get_healed_cards(card, cell)) * HEAL
