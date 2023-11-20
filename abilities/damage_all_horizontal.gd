extends PlayAbility


const DAMAGE: int = 1


func use(card: Card) -> void:
	super(card)
	var scene_tree: SceneTree = card.get_tree()
	for damaged_card in get_damaged_cards(card):
		var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
		scene_tree.current_scene.add_child(projectile)
		projectile.global_position = card.global_position
		projectile.attacker = card
		projectile.target = damaged_card
		projectile.damage = DAMAGE
		projectile.target_position = damaged_card.global_position
		projectile.z_index = 128
	while len(scene_tree.get_nodes_in_group("projectile")):
		await scene_tree.create_timer(0.01).timeout


func get_affected_cells(card: Card) -> Array[Vector2i]:
	if card.state == Card.CardState.HAND_SELECTED or card.state == Card.CardState.BOARD_SELECTED:
		return CellsHelpers.get_cells_left_and_right(
			card.target_cell,
			card.board_scale,
			5
		)
	else:
		return CellsHelpers.get_cells_left_and_right(
			card.board_cell,
			card.board_scale,
			5
		)


func get_damaged_cards(card: Card) -> Array[Card]:
	return QueryCard.get_cards_in_cells(get_affected_cells(card))
