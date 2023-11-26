extends Node


func play(sound_id: String) -> void:
	var a: Node = get_node(sound_id)
	if a is AudioStreamPlayer:
		a.play()
