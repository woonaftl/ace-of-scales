extends Node


var animation_speed: float = 8.
var opponent_turn_speed: float = 0.25


func _ready() -> void:
	get_window().min_size = Vector2i(1600, 900)
