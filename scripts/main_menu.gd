extends Control


@onready var quit_button: Button = %QuitButton as Button


func _ready() -> void:
	quit_button.visible = not OS.has_feature("web")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scripts/game.tscn")


func _on_quit_button_pressed() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()
