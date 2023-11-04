extends Node


signal user_input_failed(message: String)


func _on_user_input_failed(message: String) -> void:
	user_input_failed.emit(message)
