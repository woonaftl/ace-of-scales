extends Label


var time_since_init: float = 0.
var lifetime: float = 5.


func _process(delta: float) -> void:
	time_since_init += delta
	modulate.a -= 0.5 * delta
	if time_since_init > lifetime:
		queue_free()
