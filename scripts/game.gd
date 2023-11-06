extends Control


const ROTATED_CARDS_Y_OFFSET: float = 8.
const CARD_ROTATION: float = 0.03


var player: Player


@onready var tile_control: Control = %TileControl as Control
@onready var tile_map: TileMap = %TileMap as TileMap
@onready var energy_label: Label = %EnergyLabel as Label


func _ready():
	EventBus.user_input_failed.connect(_on_user_input_failed)
	player = Player.new()
	player.energy = 10
	_deal_cards()


func _process(_delta: float) -> void:
	energy_label.text = str(player.energy)
	# scaling card
	for scaling_card in get_tree().get_nodes_in_group("card_scaling"):
		var mouse_pos: Vector2 = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(mouse_pos) and can_scale_card_here(scaling_card):
			var mouse_board_position: Vector2i = tile_map.global_to_map(mouse_pos)
			scaling_card.is_scaling_valid = true
			scaling_card.target_position = tile_map.get_position_from_board_position_and_scale(
				Vector2i(
					min(mouse_board_position.x, scaling_card.board_position.x), 
					min(mouse_board_position.y, scaling_card.board_position.y)
				),
				scaling_card.board_scale + Vector2i.ONE
			)
		else:
			scaling_card.is_scaling_valid = false
			scaling_card.target_position = tile_map.get_position_from_board_position_and_scale(
				scaling_card.board_position,
				scaling_card.board_scale
			)
	# selected card
	for selected_card in get_tree().get_nodes_in_group("card_selected"):
		var target = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(target):
			if can_place_card_here():
				target = tile_control.snap_to_tiles_global(target)
		selected_card.target_position = target
	# cards in hand
	var cards_in_hand = get_tree().get_nodes_in_group("card_in_hand")
	var viewport_size = get_viewport_rect().size
	for index in len(cards_in_hand):
		var node = cards_in_hand[index]
		var node_size = node.get_size()
		var relative_index = index + 0.5 - len(cards_in_hand) / 2.
		var center_x = viewport_size.x / 2.
		node.target_position = Vector2(
			center_x + relative_index * node_size.x,
			viewport_size.y - node_size.y / 2. + abs(relative_index) * ROTATED_CARDS_Y_OFFSET
		)
		node.rotation = relative_index * CARD_ROTATION


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(mouse_pos):
			# scaling card up
			var scaling_card = get_tree().get_first_node_in_group("card_scaling")
			if is_instance_valid(scaling_card):
				if can_scale_card_here(scaling_card):
					if player.energy >= scaling_card.blueprint.scale_up_cost:
						var target_board_position: Vector2i = tile_map.global_to_map(mouse_pos)
						scaling_card.board_position = Vector2i(
							min(target_board_position.x, scaling_card.board_position.x), 
							min(target_board_position.y, scaling_card.board_position.y)
						)
						scaling_card.board_scale += Vector2i.ONE
						scaling_card.is_scaled_this_turn = true
						var overlapping_cards: Array = get_cards_in_square_of_cells(
							scaling_card.board_position,
							scaling_card.board_scale
						)
						for overlapping_card in overlapping_cards:
							overlapping_card.board_position = Vector2i(-1, -1)
							overlapping_card.board_scale = Vector2i.ONE
							overlapping_card.remove_from_group("card_on_board")
							overlapping_card.add_to_group("card_in_hand")
						scaling_card.remove_from_group("card_scaling")
						scaling_card.add_to_group("card_on_board")
						player.energy -= scaling_card.blueprint.scale_up_cost
					else:
						_on_user_input_failed("Not enough energy")
						scaling_card.remove_from_group("card_scaling")
						scaling_card.add_to_group("card_on_board")
				else:
					_on_user_input_failed("Cannot scale this card in this direction")
					scaling_card.remove_from_group("card_scaling")
					scaling_card.add_to_group("card_on_board")
			# placing selected card
			var selected_card = get_tree().get_first_node_in_group("card_selected")
			if is_instance_valid(selected_card):
				if can_place_card_here():
					if player.energy >= selected_card.blueprint.play_cost:
						selected_card.remove_from_group("card_selected")
						selected_card.add_to_group("card_on_board")
						selected_card.board_position = tile_map.global_to_map(mouse_pos)
						player.energy -= selected_card.blueprint.play_cost
					else:
						_on_user_input_failed("Not enough energy")
						selected_card.remove_from_group("card_selected")
						selected_card.add_to_group("card_in_hand")
				else:
					_on_user_input_failed("This place is already occupied")
					selected_card.remove_from_group("card_selected")
					selected_card.add_to_group("card_in_hand")
			get_viewport().set_input_as_handled()
		else:
			clear_selectiom()


func _on_end_turn_button_pressed() -> void:
	if not clear_selectiom():
		player.energy = 0
		for card in get_tree().get_nodes_in_group("card_on_board"):
			player.energy += card.board_scale.x * card.board_scale.y
			card.is_scaled_this_turn = false
		_deal_cards()


func _on_user_input_failed(message: String) -> void:
	var new_floating_text = preload("res://scripts/floating_hint.tscn").instantiate()
	add_child(new_floating_text)
	new_floating_text.global_position = get_global_mouse_position()
	new_floating_text.text = message


func can_place_card_here() -> bool:
	return tile_map.is_pos_vacant(get_global_mouse_position())


func can_scale_card_here(card: Node) -> bool:
	var mouse_pos: Vector2 = get_global_mouse_position()
	if tile_map.is_pos_within_playable_area(mouse_pos):
		var mouse_snapped: Vector2 = tile_control.snap_to_tiles_global(mouse_pos)
		var current_center = tile_map.get_position_from_board_position_and_scale(
			card.board_position,
			card.board_scale
		)
		var distance_x = abs(current_center.x - mouse_snapped.x)
		var distance_y = abs(current_center.y - mouse_snapped.y)
		if distance_x == distance_y and distance_x == (card.board_scale.x + 1) * 64.:
			var mouse_board_position: Vector2i = tile_map.global_to_map(mouse_pos)
			var overlapping_cards: Array = get_cards_in_square_of_cells(
				Vector2i(
					min(mouse_board_position.x, card.board_position.x), 
					min(mouse_board_position.y, card.board_position.y)
				),
				card.board_scale + Vector2i.ONE
			)
			if not overlapping_cards.any(
				func(overlapping_card):
					return overlapping_card.board_scale > card.board_scale
			):
				return true
	return false


func get_cards_in_square_of_cells(top_left_cell: Vector2i, square_size: Vector2i) -> Array:
	var result: Array = []
	for x in square_size.x + 1:
		for y in square_size.y + 1:
			result.append_array(get_cards_on_cell(top_left_cell + Vector2i(x, y)))
	return result


func get_cards_on_global_point(p_global: Vector2) -> Array:
	return get_cards_on_cell(tile_map.global_to_map(p_global))


func get_cards_on_cell(cell: Vector2i) -> Array:
	var result: Array = []
	for card in get_tree().get_nodes_in_group("card_on_board"):
		for x in card.board_scale.x:
			for y in card.board_scale.y:
				if cell == card.board_position + Vector2i(x, y):
					result.append(card)
	return result


func clear_selectiom() -> bool:
	var result: bool = false
	for node in get_tree().get_nodes_in_group("card_selected"):
		node.remove_from_group("card_selected")
		node.add_to_group("card_in_hand")
		result = true
	for node in get_tree().get_nodes_in_group("card_scaling"):
		node.remove_from_group("card_scaling")
		node.add_to_group("card_on_board")
		result = true
	return result


func _deal_cards() -> void:
	var cards_in_hand_count: int = len(get_tree().get_nodes_in_group("card_in_hand"))
	for index in 5 - cards_in_hand_count:
		var new_card = preload("res://scripts/card.tscn").instantiate()
		new_card.add_to_group("card_in_hand")
		tile_control.add_child(new_card)
		new_card.position = Vector2(0., get_viewport_rect().size.y)
		new_card.player = player
		new_card.blueprint = [
			preload("res://blueprints/ash.tres"),
			preload("res://blueprints/cinder.tres"),
			preload("res://blueprints/ember.tres")
		].pick_random()


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local
