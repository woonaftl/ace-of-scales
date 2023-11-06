extends Control


const ROTATED_CARDS_Y_OFFSET: float = 8.
const CARD_ROTATION: float = 0.03


var player: Player


@onready var tile_control: Control = %TileControl as Control
@onready var energy_label: Label = %EnergyLabel as Label


func _ready():
	EventBus.user_input_failed.connect(_on_user_input_failed)
	player = Player.new()
	player.energy = 10
	tile_control.player = player
	_deal_cards()


func _process(_delta: float) -> void:
	energy_label.text = str(player.energy)
	# selected card
	for selected_card in get_tree().get_nodes_in_group("card_selected"):
		var target = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(target):
			if tile_control.can_place_card_here():
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
		for node in get_tree().get_nodes_in_group("card_selected"):
			node.remove_from_group("card_selected")
			node.add_to_group("card_in_hand")


func _on_end_turn_button_pressed() -> void:
	var selected_card = get_tree().get_first_node_in_group("card_selected")
	if is_instance_valid(selected_card):
		selected_card.remove_from_group("card_selected")
		selected_card.add_to_group("card_in_hand")
	else:
		player.energy = len(get_tree().get_nodes_in_group("card_on_board"))
		_deal_cards()


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


func _on_user_input_failed(message: String) -> void:
	var new_floating_text = preload("res://scripts/floating_hint.tscn").instantiate()
	add_child(new_floating_text)
	new_floating_text.global_position = get_global_mouse_position()
	new_floating_text.text = message
