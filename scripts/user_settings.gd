extends Node


var characters_per_frame: int = 1
var animation_speed: float = 8.
var opponent_turn_speed: float = 0.25
var is_victory: bool = false


func _ready() -> void:
	get_window().min_size = Vector2i(1600, 900)
