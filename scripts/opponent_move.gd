extends Object
class_name OpponentMove


var card: Card
var is_scale: bool
var target: Vector2i


func _init(new_card: Card, new_is_scale: bool, new_target: Vector2i):
	card = new_card
	is_scale = new_is_scale
	target = new_target


func play():
	if is_scale and card.state == Card.CardState.BOARD:
		card.state = Card.CardState.BOARD_SCALING
		await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
		card.scale_up(target)
	elif card.state == Card.CardState.HAND:
		card.state = Card.CardState.HAND_SELECTED
		await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
		card.target_cell = target
		await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
		card.play(target)
	elif card.state == Card.CardState.BOARD:
		card.state = Card.CardState.BOARD_SELECTED
		await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
		card.target_cell = target
		await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
		card.play(target)
	await card.get_tree().create_timer(UserSettings.opponent_turn_speed).timeout
