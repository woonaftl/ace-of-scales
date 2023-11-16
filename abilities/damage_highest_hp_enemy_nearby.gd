extends Ability


var damage: int = 2


func use(card: Card) -> void:
	super(card)
	for affected_card in get_affected_cards(card):
		var projectile: Node = preload("res://scripts/flame_projectile.tscn").instantiate()
		card.get_tree().current_scene.add_child(projectile)
		projectile.global_position = card.global_position
		projectile.target_card = affected_card
		projectile.target_position = affected_card.global_position
		projectile.z_index = 128
		projectile.arrived.connect(_on_projectile_arrived)
	while len(card.get_tree().get_nodes_in_group("flame_projectile")):
		await card.get_tree().create_timer(0.01).timeout


func _on_projectile_arrived(card: Card) -> void:
	card.hit_points -= damage


func get_affected_cells(card: Card) -> Array[Vector2i]:
	if card.state == Card.CardState.HAND_SELECTED or card.state == Card.CardState.BOARD_SELECTED:
		return CellsHelpers.get_cells_near_rectangle(
			card.target_cell,
			card.board_scale
		)
	else:
		return CellsHelpers.get_cells_near_rectangle(
			card.board_cell,
			card.board_scale
		)

func get_affected_cards(card: Card) -> Array[Card]:
	var eligible_targets: Array[Card] = QueryCard.get_cards_in_cells(get_affected_cells(card)).filter(
		func(affected_card: Card):
			return affected_card.player != card.player
	)
	if len(eligible_targets) > 0:
		return [get_highest_hit_points_card(eligible_targets)]
	else:
		return []


func get_highest_hit_points_card(cards: Array[Card]) -> Card:
	var result: Card
	for next_card: Card in cards:
		if result == null or next_card.hit_points > result.hit_points:
			result = next_card
	return result
