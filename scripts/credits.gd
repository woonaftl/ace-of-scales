extends Control


@onready var victory_label: RichTextLabel = %VictoryLabel as RichTextLabel
@onready var thank_you_label: RichTextLabel = %ThankYouLabel as RichTextLabel
@onready var itch_button: Button = %ItchButton as Button


func _ready():
	victory_label.visible = UserSettings.is_victory
	thank_you_label.visible = UserSettings.is_victory
	itch_button.visible = not OS.has_feature("web")


func _on_back_button_pressed():
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://data/scenes/main_menu.tscn")


func _on_itch_button_pressed():
	AudioBus.play("Click")
	OS.shell_open("https://blackknighthalberd.itch.io")
