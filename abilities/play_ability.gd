extends Resource
class_name PlayAbility


func use(card: Card) -> void:
	await card.get_tree().create_timer(0.01).timeout
	pass


func get_affected_cells(_card: Card, _cell: Vector2i) -> Array[Vector2i]:
	return []


func get_damaged_cards(_card: Card, _cell: Vector2i) -> Array[Card]:
	return []


func get_healed_cards(_card: Card, _cell: Vector2i) -> Array[Card]:
	return []


func get_value(_card: Card, _cell: Vector2i) -> int:
	return 0
