extends CenterContainer


@onready var window_mode_button: OptionButton = %WindowModeButton as OptionButton


func _ready() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			window_mode_button.select(1)
		_:
			window_mode_button.select(0)


func _on_back_button_pressed() -> void:
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://data/scenes/main_menu.tscn")


func _on_option_button_item_selected(index: int):
	match index:
		0:
			UserSettings.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			UserSettings.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
