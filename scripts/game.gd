extends Control


const ROTATED_CARDS_Y_OFFSET: float = 8.
const CARD_ROTATION: float = 0.03


@onready var tile_control: Control = %TileControl as Control


func _ready():
	for index in range(5):
		var new_card = preload("res://scripts/card.tscn").instantiate()
		new_card.add_to_group("card_in_hand")
		add_child(new_card)
		new_card.position = Vector2(0., get_viewport_rect().size.y)


func _process(_delta: float) -> void:
	# selected card
	for selected_card in get_tree().get_nodes_in_group("card_selected"):
		var target = get_global_mouse_position()
		if tile_control.get_global_rect().has_point(target):
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
