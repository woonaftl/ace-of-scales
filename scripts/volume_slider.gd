extends HSlider


var master_bus: int = AudioServer.get_bus_index("Master")
var preview: bool = false


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	preview = true


func _on_value_changed(_value: float) -> void:
	var db: float = linear_to_db(value)
	if preview and AudioBus.get_node("ScaleUp").get_playback_position() == 0:
		AudioBus.play("ScaleUp")
	UserSettings.set_master_volume(db)
