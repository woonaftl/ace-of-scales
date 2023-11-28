extends PanelContainer


var sound_id: String


@onready var character_sprite: Sprite2D = %Sprite2D as Sprite2D
@onready var character_label: Label = %CharacterLabel as Label
@onready var line_label: RichTextLabel = %LineLabel as RichTextLabel


func _ready() -> void:
	add_to_group("dialogue")


func _process(_delta: float) -> void:
	if line_label.visible_ratio < 1:
		line_label.visible_characters += UserSettings.characters_per_frame
		if line_label.get_parsed_text().substr(line_label.visible_characters - 1, 1) != " ":
			AudioBus.play(sound_id)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if line_label.visible_ratio < 1:
			line_label.visible_characters = len(line_label.text)
			get_viewport().set_input_as_handled()
		else:
			queue_free()
			get_viewport().set_input_as_handled()


func say(character: Character, line: String) -> void:
	sound_id = character.sound
	character_label.text = tr(character.name)
	character_sprite.texture = character.texture
	line_label.text = tr(line)
