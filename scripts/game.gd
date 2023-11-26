extends Control


const POPUP_TIME_TURN = 0.75
const POPUP_TIME_END = 3.5
const ROTATED_CARDS_Y_OFFSET: float = 10.
const CARD_ROTATION_ANGLE: float = 0.04
const DEFAULT_CARDS_IN_HAND: int = 5
const BLUEPRINTS_HUMAN: Array = [
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/sapphire.tres"),
]
const BLUEPRINTS_JACK: Array = [
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/sparkle.tres"),
	preload("res://data/blueprints/sparkle.tres"),
	preload("res://data/blueprints/tempest.tres"),
]
const BLUEPRINTS_QUEEN: Array = [
	preload("res://data/blueprints/crimson.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/crimson.tres"),
	preload("res://data/blueprints/crimson.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/emerald.tres"),
	preload("res://data/blueprints/emerald.tres"),
	preload("res://data/blueprints/tempest.tres"),
	preload("res://data/blueprints/tempest.tres"),
]
const BLUEPRINTS_KING: Array = [
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/crimson.tres"),
	preload("res://data/blueprints/dawn.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/emerald.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/tempest.tres"),
]
const BLUEPRINTS_ACE: Array = [
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/sparkle.tres"),
	preload("res://data/blueprints/ember.tres"),
	preload("res://data/blueprints/obsidian.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/cinder.tres"),
	preload("res://data/blueprints/crimson.tres"),
	preload("res://data/blueprints/dawn.tres"),
	preload("res://data/blueprints/dawn.tres"),
	preload("res://data/blueprints/emerald.tres"),
	preload("res://data/blueprints/ruby.tres"),
	preload("res://data/blueprints/sapphire.tres"),
	preload("res://data/blueprints/tempest.tres"),
]


var current_turn: Player
var human: Player
var opponent: Player
var is_game_on: bool
var turn: int = 1


@onready var level: int:
	set(new_value):
		level = new_value
		for card in QueryCard.get_cards_of_player(opponent):
			card.queue_free()
		tile_map.x_max = clamp(level + 1, 2, 4)
		tile_map.y_max = clamp(level + 1, 2, 4)
		await fill_deck_opponent()
		play_starting_cards_opponent()
		_deal_cards(opponent)


@onready var tile_control: Control = %TileControl as Control
@onready var tile_map: TileMap = %TileMap as TileMap
@onready var human_energy_control: Control = %HumanEnergyControl as Control
@onready var human_energy_label: Label = %HumanEnergyLabel as Label
@onready var human_draw_pile_label: Label = %HumanDrawPileLabel as Label
@onready var human_discard_pile_label: Label = %HumanDiscardPileLabel as Label
@onready var opponent_energy_control: Control = %OpponentEnergyControl as Control
@onready var opponent_energy_label: Label = %OpponentEnergyLabel as Label
@onready var opponent_draw_pile_label: Label = %OpponentDrawPileLabel as Label
@onready var opponent_discard_pile_label: Label = %OpponentDiscardPileLabel as Label
@onready var end_turn_button: Button = %EndTurnButton as Button
@onready var tile_container: CenterContainer = %TileContainer as CenterContainer
@onready var top_left_container: VBoxContainer = %TopLeftContainer as VBoxContainer
@onready var top_right_container: VBoxContainer = %TopRightContainer as VBoxContainer
@onready var bottom_left_container: VBoxContainer = %BottomLeftContainer as VBoxContainer
@onready var bottom_right_container: VBoxContainer = %BottomRightContainer as VBoxContainer
@onready var parallax_background: ParallaxBackground = %ParallaxBackground as ParallaxBackground


func _ready():
	EventBus.user_input_failed.connect(_on_user_input_failed)
	human = Player.new()
	human.is_human = true
	opponent = Player.new()
	opponent.is_human = false
	await dialogue_opponent(
		preload("res://data/characters/jack.tres"),
		"So it says you're here to [i]free the Dragonfolk[/i]. What the hell does it even mean?"
	)
	await dialogue_human(
		"I don't think the [color=#fff082]King of Scales[/color] is a just ruler."
	)
	await dialogue_opponent(
		preload("res://data/characters/jack.tres"),
		"Whatever, in order to get to the [color=#fff082]King of Scales[/color], you need to get through me!"
	)
	await dialogue_opponent(
		preload("res://data/characters/jack.tres"),
		"And, according to our centuries old tradition, we, the Dragons, always fight with cards!"
	)
	tile_container.visible = true
	top_left_container.visible = true
	top_right_container.visible = true
	bottom_left_container.visible = true
	bottom_right_container.visible = true
	parallax_background.visible = true
	level = 1
	await fill_deck_human()
	play_starting_cards_human()
	await _prepare_turn(human)
	current_turn = human
	await show_popup("YOUR TURN", POPUP_TIME_TURN)
	is_game_on = true
	await dialogue_opponent(
		preload("res://data/characters/jack.tres"),
		"You look so tiny, I'm going to give you a first turn advantage. Just use your [img=24x24]res://assets/graphics/energy.svg[/img][color=#b482b7]energy[/color] to move the cards from your hand to the board."
	)
	await dialogue_opponent(
		preload("res://data/characters/jack.tres"),
		"When you use up all of your [img=24x24]res://assets/graphics/energy.svg[/img][color=#b482b7]energy[/color], end your turn."
	)


func fill_deck_human() -> void:
	for blueprint in BLUEPRINTS_HUMAN:
		var new_card = preload("res://data/scenes/card.tscn").instantiate()
		tile_control.add_child(new_card)
		new_card.global_position = get_viewport_rect().size / 2.
		new_card.player = human
		new_card.blueprint = blueprint
		new_card.state = Card.CardState.DRAW
		await get_tree().create_timer(0.01).timeout


func play_starting_cards_human() -> void:
	var player_deck = QueryCard.get_cards(human, Card.CardState.DRAW)
	if len(player_deck) > 0:
		player_deck[0].play(Vector2i(0, tile_map.y_max))


func fill_deck_opponent() -> void:
	var deck: Array = []
	match level:
		1:
			deck = BLUEPRINTS_JACK
		2:
			deck = BLUEPRINTS_QUEEN
		3:
			deck = BLUEPRINTS_KING
		_:
			deck = BLUEPRINTS_ACE
	for blueprint in deck:
		var new_card = preload("res://data/scenes/card.tscn").instantiate()
		tile_control.add_child(new_card)
		new_card.global_position = get_viewport_rect().size / 2.
		new_card.player = opponent
		new_card.blueprint = blueprint
		new_card.state = Card.CardState.DRAW
		await get_tree().create_timer(0.01).timeout


func play_starting_cards_opponent() -> void:
	var player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
	if len(player_deck) > 0:
		player_deck[0].play(Vector2i(tile_map.x_max, 0))
	if level > 1:
		player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
		if len(player_deck) > 0:
			player_deck[0].play(Vector2i(tile_map.x_max - 1, 0))
	if level > 2:
		player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
		if len(player_deck) > 0:
			player_deck[0].play(Vector2i(tile_map.x_max, 1))
	if level > 3:
		player_deck = QueryCard.get_cards(opponent, Card.CardState.DRAW)
		if len(player_deck) > 0:
			player_deck[0].play(Vector2i(tile_map.x_max - 2, 1))


func _process(_delta: float) -> void:
	for reset_card: Card in QueryCard.get_all_cards():
		reset_card.is_damage_highlighted = false
		reset_card.is_heal_highlighted = false
	human_energy_label.text = str(human.energy)
	opponent_energy_label.text = str(opponent.energy)
	end_turn_button.disabled = current_turn != human or not is_game_on
	# draw and discard pile counters
	var human_draw_pile_size: int = len(QueryCard.get_cards(human, Card.CardState.DRAW))
	if human_draw_pile_size > 0:
		human_draw_pile_label.text = str(human_draw_pile_size)
	else:
		human_draw_pile_label.text = ""
	var human_discard_pile_size: int = len(QueryCard.get_cards(human, Card.CardState.DISCARD))
	if human_discard_pile_size > 0:
		human_discard_pile_label.text = str(human_discard_pile_size)
	else:
		human_discard_pile_label.text = ""

	var opponent_draw_pile_size: int = len(QueryCard.get_cards(opponent, Card.CardState.DRAW))
	if opponent_draw_pile_size > 0:
		opponent_draw_pile_label.text = str(opponent_draw_pile_size)
	else:
		opponent_draw_pile_label.text = ""
	var opponent_discard_pile_size: int = len(QueryCard.get_cards(opponent, Card.CardState.DISCARD))
	if opponent_discard_pile_size > 0:
		opponent_discard_pile_label.text = str(opponent_discard_pile_size)
	else:
		opponent_discard_pile_label.text = ""
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
			if card.blueprint.play_ability != null:
				for damaged_card: Card in card.blueprint.play_ability.get_damaged_cards(card, card.target_cell):
					damaged_card.is_damage_highlighted = true
				for healed_card: Card in card.blueprint.play_ability.get_healed_cards(card, card.target_cell):
					healed_card.is_heal_highlighted = true
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
					viewport_size.y - card_size.y / 2. - 32. + abs(
						relative_index
					) * ROTATED_CARDS_Y_OFFSET
				)
				card.target_rotation = relative_index * CARD_ROTATION_ANGLE
			else:
				card.target_position = Vector2(
					center_x - relative_index * card_size.x,
					card_size.y / 2. - abs(relative_index) * ROTATED_CARDS_Y_OFFSET - 32.
				)
				card.target_rotation = relative_index * CARD_ROTATION_ANGLE + PI
	# cards in draw pile
	for card in QueryCard.get_cards_in_state(Card.CardState.DRAW):
		if card.player.is_human:
			card.target_position = human_draw_pile_label.global_position + Vector2(64., 64.)
		else:
			card.target_position = opponent_draw_pile_label.global_position + Vector2(64., 64.)
	# cards in discard pile
	for card in QueryCard.get_cards_in_state(Card.CardState.DISCARD):
		if card.player.is_human:
			card.target_position = human_discard_pile_label.global_position + Vector2(64., 64.)
		else:
			card.target_position = opponent_discard_pile_label.global_position + Vector2(64., 64.)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var particles: GPUParticles2D = preload("res://data/scenes/gpu_particles_2d.tscn").instantiate()
		add_child(particles)
		particles.global_position = mouse_pos
		particles.one_shot = true
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
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://data/scenes/main_menu.tscn")


func _on_end_turn_button_pressed() -> void:
	if current_turn != human:
		_on_user_input_failed("Not your turn")
	elif not QueryCard.clear_selectiom():
		AudioBus.play("Click")
		await check_lose()
		for card: Card in QueryCard.get_cards(human, Card.CardState.HAND):
			card.state = Card.CardState.DISCARD
		current_turn = opponent
		await _prepare_turn(opponent)
		await show_popup("ENEMY TURN", POPUP_TIME_TURN)
		await _opponent_turn()


func _on_user_input_failed(message: String) -> void:
	var new_floating_text = preload("res://data/scenes/floating_hint.tscn").instantiate()
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
		await check_lose()


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
		if card.blueprint.turn_ability != null:
			card.blueprint.turn_ability.use(card)
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
	var projectile = preload("res://data/scenes/energy_projectile.tscn").instantiate()
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
				result.append(OpponentMove.new(
					card,
					false,
					card.board_cell,
					0 + get_card_play_ability_value(card, card.board_cell)
				))
				for cell in vacant_tiles:
					if can_place_card_here(card, cell):
						result.append(OpponentMove.new(
							card,
							false,
							cell,
							0 + get_card_play_ability_value(card, cell)
						))
			if opponent.energy >= card.get_scale_up_cost():
				for cell in get_possible_scaling_directions(card):
					result.append(OpponentMove.new(
						card,
						true,
						cell,
						2 + get_card_scale_value(card, cell)
					))
	for card in QueryCard.get_cards(opponent, Card.CardState.HAND):
		if not card.is_used_this_turn:
			if opponent.energy >= card.blueprint.play_cost:
				for cell in vacant_tiles:
					if can_place_card_here(card, cell):
						result.append(OpponentMove.new(
							card,
							false,
							cell,
							1 + get_card_play_ability_value(card, cell)
						))
	return result


func get_card_play_ability_value(card: Card, cell: Vector2i) -> int:
	if card.blueprint.play_ability != null:
		@warning_ignore("integer_division")
		return card.blueprint.play_ability.get_value(card, cell) / card.blueprint.play_cost
	else:
		return 1


func get_card_scale_value(card: Card, cell: Vector2i) -> int:
	var overlapping_cards: Array = QueryCard.get_cards_in_rectangle(
		cell,
		card.board_scale + Vector2i.ONE
	)
	return 2 * len(overlapping_cards.filter(
		func(overlapping_card: Card):
			return overlapping_card.player != card.player
	)) - 2 * len(overlapping_cards.filter(
		func(overlapping_card: Card):
			return overlapping_card.player == card.player
	))


func pick_opponent_move(moves: Array[OpponentMove]) -> OpponentMove:
	var result: OpponentMove
	moves.shuffle()
	for move: OpponentMove in moves:
		if result == null:
			result = move
		elif move.value > result.value:
			result = move
	return result


func _opponent_turn() -> void:
	var moves: Array[OpponentMove] = get_possible_opponent_moves()
	while len(moves) > 0:
		await pick_opponent_move(moves).play()
		moves = get_possible_opponent_moves()
	for card: Card in QueryCard.get_cards(opponent, Card.CardState.HAND):
		card.state = Card.CardState.DISCARD
	await get_tree().create_timer(1.).timeout
	await check_lose()
	if is_game_on:
		await _prepare_turn(human)
		current_turn = human
		await show_popup("YOUR TURN", POPUP_TIME_TURN)
		turn += 1
		if level == 1 and turn == 2:
			await dialogue_opponent(
				preload("res://data/characters/jack.tres"),
				"When your turn starts, you get [img=24x24]res://assets/graphics/energy.svg[/img][color=#b482b7]energy[/color] for each cell on the board occupied by your cards. For us dragons, territory is everything."
			)
			await dialogue_opponent(
				preload("res://data/characters/jack.tres"),
				"You can play not only the cards in your hand, but move around the cards already on the board, too. But it costs [img=24x24]res://assets/graphics/energy.svg[/img][color=#b482b7]energy[/color]."
			)
		elif level == 1 and turn == 3:
			await dialogue_opponent(
				preload("res://data/characters/jack.tres"),
				"Once you get enough energy, you can [img=24x24]res://assets/graphics/scale_up.svg[/img][color=#b8657e]scale[/color] your cards! Bigger equals better! Bigger card captures everyone below it right into your hand!"
			)


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


func check_lose() -> void:
	if is_game_on:
		if len(QueryCard.get_cards(human, Card.CardState.BOARD)) + len(
			QueryCard.get_cards(human, Card.CardState.BOARD_SCALING)
		) + len(
			QueryCard.get_cards(human, Card.CardState.BOARD_SELECTED)
		) == 0:
			is_game_on = false
			await show_popup("GAME OVER", POPUP_TIME_END)
			clear_board()
			if level < 2:
				await dialogue_opponent(
					preload("res://data/characters/jack.tres"),
					"If you have no cards on board, you lose. Did I forget to tell you that? Oops."
				)
			elif level < 3:
				await dialogue_opponent(
					preload("res://data/characters/queen.tres"),
					"Haha, get good before you dare to challenge me! I'm in a good mood today but next time your bones are going straight into the gorge!"
				)
			elif level < 4:
				await dialogue_opponent(
					preload("res://data/characters/king.tres"),
					"Know your place, [b]peasant[/b]."
				)
			else:
				await dialogue_opponent(
					preload("res://data/characters/ace.tres"),
					"Such a shame that your talent is wasted on this character. You could have been a [color=#fff082]King[/color], but you wanted more..."
				)
			get_tree().change_scene_to_file("res://data/scenes/main_menu.tscn")
		elif len(QueryCard.get_cards(opponent, Card.CardState.BOARD)) + len(
			QueryCard.get_cards(opponent, Card.CardState.BOARD_SCALING)
		) + len(
			QueryCard.get_cards(opponent, Card.CardState.BOARD_SELECTED)
		) == 0:
			is_game_on = false
			await show_popup("VICTORY", POPUP_TIME_END)
			clear_board()
			if level < 2:
				await dialogue_opponent(
					preload("res://data/characters/jack.tres"),
					"I can't believe you've done it. I've just taught you how to play and you've already beaten me..."
				)
				await dialogue_opponent(
					preload("res://data/characters/jack.tres"),
					"Mom! Mommy!"
				)
				next_level()
			elif level < 3:
				await dialogue_opponent(
					preload("res://data/characters/queen.tres"),
					"My minions! They fail me again and again. Also, I had such terrible luck and this card game doesn't require any skill or strength..."
				)
				await dialogue_human(
					"Just move out of my way, [b]loser[/b]."
				)
				next_level()
			elif level < 4:
				await dialogue_opponent(
					preload("res://data/characters/king.tres"),
					"I can't believe it. I have never lost this game before... Does it mean you're the new [color=#fff082]King[/color]? The rules of this game are so ancient I forgot them..."
				)
				await dialogue_human(
					"Down with monarchy! I demand freedom for all of Dragonfolk!"
				)
				await dialogue_opponent(
					preload("res://data/characters/ace.tres"),
					"Freedom? Do you even know what it takes to be truly free, [b]mortal[/b]?"
				)
				next_level()
			else:
				await dialogue_opponent(
					preload("res://data/characters/ace.tres"),
					"Nooooooooooooooooooooo"
				)
				UserSettings.is_victory = true
				get_tree().change_scene_to_file("res://data/scenes/credits.tscn")


func clear_board():
	for card: Card in QueryCard.get_cards_of_player(human):
		card.state = Card.CardState.DRAW


func next_level():
	level += 1
	play_starting_cards_human()
	await _prepare_turn(human)
	current_turn = human
	await show_popup("YOUR TURN", POPUP_TIME_TURN)
	is_game_on = true
	if level == 2:
		await dialogue_opponent(
			preload("res://data/characters/queen.tres"),
			"You rascal! I'm the [color=#fff082]Queen of Scales[/color] and I'm going to show you your place!"
		)
		await dialogue_opponent(
			preload("res://data/characters/queen.tres"),
			"And your place is low, very low, in the depths of the deepest and darkest ravine, where I throw bones of my enemies."
		)
		await dialogue_opponent(
			preload("res://data/characters/queen.tres"),
			"Bones I burn to ashes."
		)
		await dialogue_human(
			"There aren't too many bones there if the ravine is so deep."
		)
		await dialogue_opponent(
			preload("res://data/characters/queen.tres"),
			"Oh, you know nothing! Enough of that!"
		)
	elif level == 3:
		await dialogue_opponent(
			preload("res://data/characters/king.tres"),
			"I am the [color=#fff082]King of Scales[/color]! Get ready to fight!"
		)
	elif level == 4:
		await dialogue_opponent(
			preload("res://data/characters/ace.tres"),
			"I am the [color=#fff082]Ace of Scales[/color]. You'll find your freedom in the grave."
		)


func show_popup(message: String, popup_time: float) -> void:
	var popup_label: Node = preload("res://data/scenes/popup_label.tscn").instantiate()
	add_child(popup_label)
	popup_label.life_span = popup_time
	popup_label.display_text(message)
	await popup_label.done


func dialogue_human(line: String) -> void:
	var dialogue: Node = preload("res://data/scenes/dialogue_box.tscn").instantiate()
	add_child(dialogue)
	dialogue.global_position = Vector2(7, 663)
	dialogue.say(preload("res://data/characters/you.tres"), line)
	while len(get_tree().get_nodes_in_group("dialogue")) > 0:
		await get_tree().create_timer(0.01).timeout


func dialogue_opponent(character: Character, line: String) -> void:
	var dialogue = preload("res://data/scenes/dialogue_box.tscn").instantiate()
	add_child(dialogue)
	dialogue.global_position = Vector2(7, 63)
	dialogue.say(character, line)
	while len(get_tree().get_nodes_in_group("dialogue")) > 0:
		await get_tree().create_timer(0.01).timeout


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
