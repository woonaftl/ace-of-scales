extends Node


var characters_per_frame: int = 1
var animation_speed: float = 8.
var opponent_turn_speed: float = 0.25
var is_victory: bool = false


func _ready() -> void:
	get_window().min_size = Vector2i(1600, 900)
	set_effects_volume(-10)
	set_background_volume(-10)


func set_effects_volume(new_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), new_value)


func set_background_volume(new_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), new_value)


func window_set_mode(new_value: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(new_value)


func set_locale(new_value: String) -> void:
	TranslationServer.set_locale(new_value)
