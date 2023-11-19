extends RichTextLabel


signal done


var age: float
var life_span: float


func _process(delta: float) -> void:
	age += delta
	if age >= life_span:
		done.emit()
		queue_free()
	add_theme_font_size_override("normal_font_size", lerp(64, 96, age))
