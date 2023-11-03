extends Area2D


const SPEED = 8.


var player
var blueprint
var is_mouse_inside = false
var is_selectable = false
var target_position: Vector2


@onready var scale_up_button: Button = %ScaleUpButton as Button
@onready var sprite: Sprite2D = %Sprite2D as Sprite2D


func _process(delta: float) -> void:
	if is_in_group("card_selected"):
		is_selectable = false
		scale_up_button.visible = false
		z_index = 16
		rotation = 0.
	elif is_in_group("card_on_board"):
		is_selectable = false
		scale_up_button.visible = true
		z_index = 0
	elif is_in_group("card_in_hand"):
		is_selectable = true
		scale_up_button.visible = false
		z_index = 0
	# movement
	var distance = global_position.distance_to(target_position)
	global_position = global_position.move_toward(target_position, delta * SPEED * distance)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_selectable and is_mouse_inside:
		for selected_card in get_tree().get_nodes_in_group("card_selected"):
			selected_card.add_to_group("card_in_hand")
			selected_card.remove_from_group("card_selected")
		add_to_group("card_selected")
		remove_from_group("card_in_hand")
		get_viewport().set_input_as_handled()


func get_size():
	return sprite.texture.get_size()


func _on_mouse_entered():
	is_mouse_inside = true


func _on_mouse_exited():
	is_mouse_inside = false
