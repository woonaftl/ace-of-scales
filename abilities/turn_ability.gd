extends Resource
class_name TurnAbility


func use(card: Card) -> void:
	await card.get_tree().create_timer(0.01).timeout
	pass
