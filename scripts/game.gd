extends Control


const ROTATED_CARDS_Y_OFFSET: float = 10.
const CARD_ROTATION_ANGLE: float = 0.04
const DEFAULT_CARDS_IN_HAND: int = 5
const ALL_BLUEPRINTS: Array = [
	preload("res://blueprints/ash.tres"),
	preload("res://blueprints/cinder.tres"),
	preload("res://blueprints/ember.tres")
]


var current_turn: Player:
	set(new_value):
		current_turn = new_value


var human: Player
var opponent: Player


var level: int = 1:
	set(new_value):
		level = new_value
		for card in QueryCard.get_cards_of_player(opponent):
			card.queue_free()
		tile_map.x_max = level + 1
		tile_map.y_max = level + 1
		await fill_deck_opponent()
		play_starting_cards_opponent()
		_deal_cards(opponent)


@onready var game_over_dialog: AcceptDialog = %GameOverDialog as AcceptDialog
@onready var level_complete_dialog: AcceptDialog = %LevelCompleteDialog as AcceptDialog
@onready var victory_dialog: AcceptDialog = %VictoryDialog as AcceptDialog
@onready var tile_control: Control = %TileControl as Control
@onready var tile_map: TileMap = %TileMap as TileMap
@onready var human_energy_control: Control = %HumanEnergyControl as Control
@onready var human_energy_label: Label = %HumanEnergyLabel as Label
@onready var human_deck_label: Label = %HumanDeckLabel as Label
@onready var opponent_energy_control: Control = %OpponentEnergyControl as Control
@onready var opponent_energy_label: Label = %OpponentEnergyLabel as Label
@onready var opponent_deck_label: Label = %OpponentDeckLabel as Label
@onready var end_turn_button: Button = %EndTurnButton as Button


func _ready():
	EventBus.user_input_failed.connect(_on_user_input_failed)
	human = Player.new()
	human.is_human = true
	opponent = Player.new()
	opponent.is_human = false
	level = 1
	await fill_deck_human()
	play_starting_cards_human()
	await _prepare_turn(human)
	current_turn = human


func fill_deck_human() -> void:
	for blueprint in ALL_BLUEPRINTS:
		for index in 5:
			var new_card = preload("res://scripts/card.tscn").instantiate()
			tile_control.add_child(new_card)
			new_card.player = human
			new_card.blueprint = blueprint
			new_card.state = Card.CardState.DRAW
			await get_tree().create_timer(0.01).timeout


func play_starting_cards_human() -> void:
	var player_deck = QueryCard.get_cards(human, Card.CardState.DRAW)
	if len(player_deck) > 0:
		player_deck.pick_random().play(Vector2i(0, tile_map.y_max))


func fill_deck_opponent() -> void:
	for blueprint in ALL_BLUEPRINTS:
		for index in 5:
			var new_card = preload("res://scripts/card.tscn").instantiate()
			tile_control.add_child(new_card)
			new_card.player = opponent
			new_card.blueprint = blueprint
			new_card.state = Card.CardState.DRAW
			await get_tree().create_timer(0.01).timeout


func play_starting_cards_opponent() -> void:
	var player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
	if len(player_deck) > 0:
		player_deck.pick_random().play(Vector2i(tile_map.x_max, 0))
	if level > 1:
		player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
		if len(player_deck) > 0:
			player_deck.pick_random().play(Vector2i(tile_map.x_max - 1, 0))
	if level > 2:
		player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
		if len(player_deck) > 0:
			player_deck.pick_random().play(Vector2i(tile_map.x_max, 1))


func _process(_delta: float) -> void:
	for reset_card: Card in QueryCard.get_all_cards():
		reset_card.is_highlighted = false
	human_energy_label.text = str(human.energy)
	opponent_energy_label.text = str(opponent.energy)
	end_turn_button.visible = current_turn == human
	human_deck_label.text = str(len(QueryCard.get_cards(human, Card.CardState.DRAW)))
	opponent_deck_label.text = str(len(QueryCard.get_cards(opponent, Card.CardState.DRAW)))
	# scaling card
	for card in QueryCard.get_cards(human, Card.CardState.BOARD_SCALING):
		var mouse_pos: Vector2 = get_global_mouse_position()
		var mouse_board_cell: Vector2i = tile_map.global_to_map(mouse_pos)
		if tile_control.get_global_rect().has_point(mouse_pos) and can_scale_card_here(
			card,
			mouse_board_cell
		):
			card.is_scaling_valid = true
			card.target_position = tile_map.get_position_from_board_cell_and_scale(
				Vector2i(
					min(mouse_board_cell.x, card.board_cell.x), 
					min(mouse_board_cell.y, card.board_cell.y)
				),
				card.board_scale + Vector2i.ONE
			)
		else:
			card.is_scaling_valid = false
			card.target_position = tile_map.get_position_from_board_cell_and_scale(
				card.board_cell,
				card.board_scale
			)
	# move selected card from hand to mouse cursor
	for card in QueryCard.get_cards(human, Card.CardState.HAND_SELECTED):
		var target_position = get_global_mouse_position()
		var target_cell = Vector2i(-1, -1)
		if tile_control.get_global_rect().has_point(target_position):
			target_cell = tile_map.global_to_map(target_position)
		card.target_cell = target_cell
		card.target_position = target_position
	# move selected card from board to mouse cursor
	for card in QueryCard.get_cards(human, Card.CardState.BOARD_SELECTED):
		var target_position = tile_map.get_position_from_board_cell_and_scale(
			card.board_cell,
			card.board_scale
		)
		var target_cell = Vector2i(-1, -1)
		if tile_control.get_global_rect().has_point(target_position):
			target_position = get_global_mouse_position()
			target_cell = tile_map.global_to_map(target_position)
		card.target_cell = target_cell
		card.target_position = target_position
	for card in QueryCard.get_cards_in_states([
		Card.CardState.BOARD_SELECTED,
		Card.CardState.HAND_SELECTED
	]):
		if can_place_card_here(card, card.target_cell):
			# snap card to cell
			card.target_position = tile_map.get_position_from_board_cell_and_scale(
				card.target_cell,
				card.board_scale
			)
			# highlight which cards will be affected if played
			for affected_card: Card in card.blueprint.ability.get_affected_cards(card):
				affected_card.is_highlighted = true
	# cards in hand
	for player in [human, opponent]:
		var cards_in_hand = QueryCard.get_cards(player, Card.CardState.HAND)
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
				card.target_rotation = relative_index * CARD_ROTATION_ANGLE
			else:
				card.target_position = Vector2(
					center_x - relative_index * card_size.x,
					card_size.y / 2. - abs(relative_index) * ROTATED_CARDS_Y_OFFSET
				)
				card.target_rotation = relative_index * CARD_ROTATION_ANGLE + PI
	# cards in deck
	for card in QueryCard.get_cards_in_state(Card.CardState.DRAW):
		if card.player.is_human:
			card.target_position = Vector2(64., get_viewport_rect().size.y - 64.)
		else:
			card.target_position = Vector2(get_viewport_rect().size.x - 64., 64.)
	for card in QueryCard.get_cards_in_state(Card.CardState.DISCARD):
		if card.player.is_human:
			card.target_position = Vector2(
				get_viewport_rect().size.x - 64.,
				get_viewport_rect().size.y - 64.
			)
		else:
			card.target_position = Vector2(64., 64.)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(mouse_pos):
			var cell: Vector2i = tile_map.global_to_map(mouse_pos)
			for card: Card in QueryCard.get_cards(human, Card.CardState.BOARD_SCALING):
				scale_card(card, cell)
			for card: Card in QueryCard.get_cards(human, Card.CardState.BOARD_SELECTED):
				play_card(card, cell)
			for card: Card in QueryCard.get_cards(human, Card.CardState.HAND_SELECTED):
				play_card(card, cell)
			get_viewport().set_input_as_handled()
		else:
			QueryCard.clear_selectiom()


func _on_back_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://scripts/main_menu.tscn")


func _on_end_turn_button_pressed() -> void:
	if current_turn != human:
		_on_user_input_failed("Not your turn")
	elif not QueryCard.clear_selectiom():
		for card: Card in QueryCard.get_cards(human, Card.CardState.HAND):
			card.state = Card.CardState.DISCARD
		current_turn = opponent
		await _prepare_turn(opponent)
		await _opponent_turn()
		await _prepare_turn(human)
		current_turn = human
		_check_lose()


func _on_game_over_dialog_confirmed():
	get_tree().change_scene_to_file("res://scripts/main_menu.tscn")


func _on_victory_dialog_confirmed():
	get_tree().change_scene_to_file("res://scripts/main_menu.tscn")


func _on_level_complete_dialog_confirmed():
	for card: Card in QueryCard.get_cards_of_player(human):
		card.state = Card.CardState.DRAW
	level += 1
	play_starting_cards_human()
	await _prepare_turn(human)
	current_turn = human


func _on_user_input_failed(message: String) -> void:
	var new_floating_text = preload("res://scripts/floating_hint.tscn").instantiate()
	add_child(new_floating_text)
	new_floating_text.global_position = get_global_mouse_position()
	new_floating_text.text = message


func play_card(card: Card, board_cell: Vector2i) -> void:
	if current_turn != card.player:
		_on_user_input_failed("Not your turn")
	elif card.player.energy < card.blueprint.play_cost:
		_on_user_input_failed("Not enough energy")
		if card.state == Card.CardState.HAND_SELECTED:
			card.state = Card.CardState.HAND
		elif card.state == Card.CardState.BOARD_SELECTED:
			card.state = Card.CardState.BOARD
	elif not can_place_card_here(card, board_cell):
		_on_user_input_failed("This place is already occupied")
		if card.state == Card.CardState.HAND_SELECTED:
			card.state = Card.CardState.HAND
		elif card.state == Card.CardState.BOARD_SELECTED:
			card.state = Card.CardState.BOARD
	else:
		card.play(board_cell)


func scale_card(card: Card, board_direction: Vector2i) -> void:
	var cost: int = card.get_scale_up_cost()
	if current_turn != card.player:
		_on_user_input_failed("Not your turn")
	elif not can_scale_card_here(card, board_direction):
		_on_user_input_failed("Cannot scale this card in this direction")
		card.state = Card.CardState.BOARD
	elif card.player.energy < cost:
		_on_user_input_failed("Not enough energy")
		card.state = Card.CardState.BOARD
	else:
		card.scale_up(board_direction)


func can_place_card_here(card, target_cell: Vector2i) -> bool:
	return card.get_occupied_cells(target_cell).all(
		func(cell: Vector2i):
			return tile_map.is_cell_vacant(cell)
	)


func can_scale_card_here(card: Node, board_direction: Vector2i) -> bool:
	if tile_map.is_cell_within_playable_area(board_direction):
		var p_global: Vector2 = tile_map.map_to_global(board_direction)
		var current_center = tile_map.get_position_from_board_cell_and_scale(
			card.board_cell,
			card.board_scale
		)
		var distance_x = abs(current_center.x - p_global.x)
		var distance_y = abs(current_center.y - p_global.y)
		if distance_x == distance_y and distance_x == (card.board_scale.x + 1) * 64.:
			var overlapping_cards: Array = QueryCard.get_cards_in_rectangle(
				Vector2i(
					min(board_direction.x, card.board_cell.x), 
					min(board_direction.y, card.board_cell.y)
				),
				card.board_scale + Vector2i.ONE
			)
			if not overlapping_cards.any(
				func(overlapping_card):
					return overlapping_card != card and overlapping_card.board_scale > Vector2i.ONE
			):
				return true
	return false


func _prepare_turn(player: Player) -> void:
	player.energy = 0
	for card: Card in QueryCard.get_cards(player, Card.CardState.BOARD):
		for _index in card.board_scale.x * card.board_scale.y:
			add_energy(
				card.global_position + Vector2(
					randf_range(-64. * card.board_scale.x, 64. * card.board_scale.x),
					randf_range(-64. * card.board_scale.y, 64. * card.board_scale.y)
				),
				card.player
			)
		card.reset()
	while len(get_tree().get_nodes_in_group("energy_projectile")):
		await get_tree().create_timer(0.01).timeout
	_deal_cards(player)


func add_energy(p_global: Vector2, player: Player) -> void:
	var projectile = preload("res://scripts/energy_projectile.tscn").instantiate()
	add_child(projectile)
	projectile.global_position = p_global
	projectile.scale = Vector2(0.2, 0.2)
	projectile.player = player
	if player.is_human:
		projectile.texture = preload("res://assets/graphics/energy.svg")
		projectile.target_position = human_energy_control.global_position + Vector2(64., 64.)
	else:
		projectile.texture = preload("res://assets/graphics/energy_opponent.svg")
		projectile.target_position = opponent_energy_control.global_position + Vector2(64., 64.)
	projectile.z_index = 128
	projectile.arrived.connect(_on_projectile_arrived)


func _on_projectile_arrived(player):
	player.energy += 1


func _deal_cards(player: Player) -> void:
	var cards_in_hand = QueryCard.get_cards(player, Card.CardState.HAND)
	for index in DEFAULT_CARDS_IN_HAND - len(cards_in_hand):
		if not deal_card(player):
			for card: Card in QueryCard.get_cards(player, Card.CardState.DISCARD):
				card.state = Card.CardState.DRAW
			deal_card(player)


func deal_card(player: Player) -> bool:
	var cards_in_deck: Array = QueryCard.get_cards(player, Card.CardState.DRAW)
	if len(cards_in_deck) > 0:
		var card_dealt: Card = cards_in_deck.pick_random()
		card_dealt.state = Card.CardState.HAND
		return true
	return false


func get_possible_opponent_moves() -> Array[OpponentMove]:
	var result: Array[OpponentMove] = []
	var vacant_tiles = get_vacant_tiles()
	for card in QueryCard.get_cards(opponent, Card.CardState.BOARD):
		if not card.is_used_this_turn:
			if opponent.energy >= card.blueprint.play_cost:
				result.append(OpponentMove.new(card, false, card.board_cell))
				for cell in vacant_tiles:
					if can_place_card_here(card, cell):
						result.append(OpponentMove.new(card, false, cell))
			if opponent.energy >= card.get_scale_up_cost():
				for cell in get_possible_scaling_directions(card):
					result.append(OpponentMove.new(card, true, cell))
	for card in QueryCard.get_cards(opponent, Card.CardState.HAND):
		if not card.is_used_this_turn:
			if opponent.energy >= card.blueprint.play_cost:
				for cell in vacant_tiles:
					if can_place_card_here(card, cell):
						result.append(OpponentMove.new(card, false, cell))
	return result


func pick_opponent_move(moves: Array[OpponentMove]) -> OpponentMove:
	var result: OpponentMove
	moves.shuffle()
	for move: OpponentMove in moves:
		if result == null:
			result = move
		elif move.is_scale:
			if not result.is_scale:
				result = move
			elif move.card.board_scale > result.card.board_scale:
				result = move
		elif not result.is_scale:
			if move.card.state == Card.CardState.HAND:
				if result.card.state != Card.CardState.HAND:
					result = move
	return result


func _opponent_turn() -> void:
	var moves: Array[OpponentMove] = get_possible_opponent_moves()
	while len(moves) > 0:
		await pick_opponent_move(moves).play()
		moves = get_possible_opponent_moves()
	for card: Card in QueryCard.get_cards(opponent, Card.CardState.HAND):
		card.state = Card.CardState.DISCARD


func get_possible_scaling_directions(card: Card) -> Array:
	var result: Array = []
	for direction in [
		Vector2i(-1, -1),
		Vector2i(-1, card.board_scale.y),
		Vector2i(card.board_scale.x, -1),
		Vector2i(card.board_scale.x, card.board_scale.y)
	]:
		var board_direction: Vector2i = card.board_cell + direction
		if can_scale_card_here(card, board_direction):
			result.append(board_direction)
	return result


func _check_lose() -> void:
	if len(QueryCard.get_cards(human, Card.CardState.BOARD)) + len(
		QueryCard.get_cards(human, Card.CardState.BOARD_SCALING)
	) == 0:
		game_over_dialog.popup_centered()
		await game_over_dialog.canceled
	elif len(QueryCard.get_cards(opponent, Card.CardState.BOARD)) + len(
		QueryCard.get_cards(opponent, Card.CardState.BOARD_SCALING)
	) == 0:
		if level < 3:
			level_complete_dialog.popup_centered()
			await level_complete_dialog.canceled
		else:
			victory_dialog.popup_centered()
			await victory_dialog.canceled


func get_vacant_tiles() -> Array:
	var result: Array = []
	for x: int in tile_map.x_max + 1:
		for y: int in tile_map.y_max + 1:
			var cell: Vector2i = Vector2i(x, y)
			if tile_map.is_cell_vacant(cell):
				result.append(cell)
	return result


func to_local(p_global: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p_global


func to_global(p_local: Vector2) -> Vector2:
	return get_global_transform() * p_local
