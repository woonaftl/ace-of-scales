extends Control


const ROTATED_CARDS_Y_OFFSET: float = 10.
const CARD_ROTATION: float = 0.04
const DEFAULT_CARDS_IN_HAND: int = 5
const ALL_BLUEPRINTS: Array = [
	preload("res://blueprints/ash.tres"),
	preload("res://blueprints/cinder.tres"),
	preload("res://blueprints/ember.tres")
]

var human: Player
var opponent: Player


@onready var tile_control: Control = %TileControl as Control
@onready var tile_map: TileMap = %TileMap as TileMap
@onready var human_energy_label: Label = %HumanEnergyLabel as Label
@onready var human_deck_label: Label = %HumanDeckLabel as Label
@onready var opponent_energy_label: Label = %OpponentEnergyLabel as Label
@onready var opponent_deck_label: Label = %OpponentDeckLabel as Label


func _ready():
	EventBus.user_input_failed.connect(_on_user_input_failed)
	human = Player.new()
	human.energy = 1
	human.is_human = true
	opponent = Player.new()
	opponent.energy = 1
	opponent.is_human = false
	for player in [human, opponent]:
		for blueprint in ALL_BLUEPRINTS:
			for index in 5:
				var new_card = preload("res://scripts/card.tscn").instantiate()
				new_card.add_to_group("card_in_deck")
				tile_control.add_child(new_card)
				new_card.player = player
				new_card.blueprint = blueprint
		var player_deck = get_tree().get_nodes_in_group("card_in_deck").filter(
			func(card):
				return card.player == player
		)
		var starting_card: Node = player_deck.pick_random()
		starting_card.remove_from_group("card_in_deck")
		starting_card.add_to_group("card_on_board")
		if player == human:
			starting_card.board_position = Vector2i(1, 2)
		if player == opponent:
			starting_card.board_position = Vector2i(1, 0)
	await get_tree().create_timer(0.1).timeout
	_deal_cards(opponent)
	_deal_cards(human)


func _process(_delta: float) -> void:
	human_energy_label.text = str(human.energy)
	opponent_energy_label.text = str(opponent.energy)
	human_deck_label.text = str(len(get_tree().get_nodes_in_group("card_in_deck").filter(
		func(card):
			return card.player == human
	)))
	opponent_deck_label.text = str(len(get_tree().get_nodes_in_group("card_in_deck").filter(
		func(card):
			return card.player == opponent
	)))
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
	for player in [human, opponent]:
		var cards_in_hand = get_tree().get_nodes_in_group("card_in_hand").filter(
			func(card):
				return card.player == player
		)
		var viewport_size = get_viewport_rect().size
		for index in len(cards_in_hand):
			var card: Node = cards_in_hand[index]
			var card_size = card.get_size()
			var relative_index = index + 0.5 - len(cards_in_hand) / 2.
			var center_x = viewport_size.x / 2.
			if card.player.is_human:
				card.target_position = Vector2(
					center_x + relative_index * card_size.x,
					viewport_size.y - card_size.y / 2. + abs(relative_index) * ROTATED_CARDS_Y_OFFSET
				)
				card.rotation = relative_index * CARD_ROTATION
			else:
				card.target_position = Vector2(
					center_x - relative_index * card_size.x,
					card_size.y / 2. - abs(relative_index) * ROTATED_CARDS_Y_OFFSET
				)
				card.rotation = relative_index * CARD_ROTATION + PI
	# cards in deck
	for card in get_tree().get_nodes_in_group("card_in_deck"):
		if card.player.is_human:
			card.target_position = Vector2(64., get_viewport_rect().size.y - 64.)
		else:
			card.target_position = Vector2(get_viewport_rect().size.x - 64., 64.)
	_check_lose()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(mouse_pos):
			# scaling card up
			var scaling_card = get_tree().get_first_node_in_group("card_scaling")
			if is_instance_valid(scaling_card):
				if can_scale_card_here(scaling_card):
					if human.energy >= scaling_card.blueprint.scale_up_cost:
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
							overlapping_card.add_to_group("card_in_deck")
							overlapping_card.player = scaling_card.player
						scaling_card.remove_from_group("card_scaling")
						scaling_card.add_to_group("card_on_board")
						human.energy -= scaling_card.blueprint.scale_up_cost
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
					if human.energy >= selected_card.blueprint.play_cost:
						selected_card.remove_from_group("card_selected")
						selected_card.add_to_group("card_on_board")
						selected_card.board_position = tile_map.global_to_map(mouse_pos)
						human.energy -= selected_card.blueprint.play_cost
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
		for player in [human, opponent]:
			player.energy = 0
			for card in get_tree().get_nodes_in_group("card_on_board").filter(
				func(card):
					return card.player == player
			):
				player.energy += card.board_scale.x * card.board_scale.y
				card.is_scaled_this_turn = false
			_deal_cards(player)


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
	for x in square_size.x:
		for y in square_size.y:
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


func _deal_cards(player: Player) -> void:
	var cards_in_hand = get_tree().get_nodes_in_group("card_in_hand").filter(
		func(card):
			return card.player == player
	)
	for index in DEFAULT_CARDS_IN_HAND - len(cards_in_hand):
		var cards_in_deck = get_tree().get_nodes_in_group("card_in_deck").filter(
			func(card):
				return card.player == player
		)
		var card_dealt: Node = cards_in_deck.pick_random()
		card_dealt.remove_from_group("card_in_deck")
		card_dealt.add_to_group("card_in_hand")


func _check_lose() -> void:
	for player in [human, opponent]:
		var cards_on_board = get_tree().get_nodes_in_group("card_on_board").filter(
			func(card):
				return card.player == player
		)
		if len(cards_on_board) == 0:
			if player == human:
				_on_user_input_failed("You lose")
			else:
				_on_user_input_failed("You win")


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local
