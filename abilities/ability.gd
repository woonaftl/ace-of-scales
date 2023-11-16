extends Resource
class_name Ability


@export var description: String


func use(_card: Card) -> void:
	pass


func get_affected_cells(_card: Card) -> Array[Vector2i]:
	return []


func get_affected_cards(_card: Card) -> Array[Card]:
	return []
