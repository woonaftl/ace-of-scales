extends CenterContainer


signal done


var age: float
var life_span: float
var text: String


@onready var label: RichTextLabel = %Label as RichTextLabel
@onready var control: Control = %Control as Control


func _process(delta: float) -> void:
	age += delta
	if age >= life_span:
		done.emit()
		queue_free()
	label.scale = lerp(Vector2(0.5, 0.5), Vector2.ONE, age / life_span)
	control.custom_minimum_size = label.size * label.scale
	label.position = Vector2.ZERO
	visible = true


func display_text(new_text: String) -> void:
	label.text = new_text
