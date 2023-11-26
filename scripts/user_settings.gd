extends Node


var characters_per_frame: int = 1
var animation_speed: float = 8.
var opponent_turn_speed: float = 0.25
var is_victory: bool = false
var master_bus: int = AudioServer.get_bus_index("Master")


func _ready() -> void:
	get_window().min_size = Vector2i(1600, 900)
	set_master_volume(-10)


func set_master_volume(new_value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, new_value)


func window_set_mode(new_value: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(new_value)
