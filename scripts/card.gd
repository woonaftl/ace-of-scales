extends Area2D


const SPEED = 8.


signal user_input_failed(message: String)


var is_mouse_inside = false
var is_selectable = false
var target_position: Vector2
var board_position: Vector2i
var hit_points: int
var is_scale_animation_increasing: bool = true
var is_scaled_this_turn: bool = false
var is_scaling_valid: bool = false
var board_scale: Vector2i = Vector2i.ONE


@onready var sprite: Sprite2D = %Sprite2D as Sprite2D
@onready var card_container: MarginContainer = %CardContainer as MarginContainer
@onready var dragon_sprite: Sprite2D = %DragonSprite as Sprite2D
@onready var name_label: Label = %NameLabel as Label
@onready var text_label: Label = %TextLabel as Label
@onready var energy_control: Control = %EnergyControl as Control
@onready var energy_label: Label = %EnergyLabel as Label
@onready var scale_up_control: Control = %ScaleUpControl as Control
@onready var scale_up_label: Label = %ScaleUpLabel as Label
@onready var hit_points_control: Control = %HitPointsControl as Control
@onready var hit_points_label: Label = %HitPointsLabel as Label
@onready var player: Player


@onready var blueprint: Blueprint:
	set(new_value):
		blueprint = new_value
		name_label.text = blueprint.name
		text_label.text = blueprint.description
		energy_label.text = str(blueprint.play_cost)
		scale_up_label.text = str(blueprint.scale_up_cost)
		hit_points = blueprint.hit_points
		dragon_sprite.texture = blueprint.texture


func _ready() -> void:
	user_input_failed.connect(EventBus._on_user_input_failed)


func _process(delta: float) -> void:
	hit_points_label.text = str(hit_points)
	hit_points_control.visible = board_scale > Vector2i.ONE
	if is_in_group("card_selected"):
		if player.is_human:
			sprite.texture = preload("res://assets/graphics/card_blank_blue.svg")
		else:
			sprite.texture = preload("res://assets/graphics/card_blank_red.svg")
		card_container.visible = true
		is_selectable = false
		energy_control.visible = true
		scale_up_control.visible = false
		z_index = 16
		rotation = 0.
		scale = board_scale
	elif is_in_group("card_in_deck"):
		if player.is_human:
			sprite.texture = preload("res://assets/graphics/card_back_blue.svg")
		else:
			sprite.texture = preload("res://assets/graphics/card_back_red.svg")
		card_container.visible = false
		is_selectable = false
		z_index = 0
		rotation = 0.
		scale = board_scale
	elif is_in_group("card_on_board"):
		if player.is_human:
			sprite.texture = preload("res://assets/graphics/card_blank_blue.svg")
		else:
			sprite.texture = preload("res://assets/graphics/card_blank_red.svg")
		card_container.visible = true
		is_selectable = false
		energy_control.visible = false
		scale_up_control.visible = true
		scale_up_control.modulate = Color.WHITE
		z_index = 0
		scale = board_scale
	elif is_in_group("card_in_hand"):
		if player.is_human:
			sprite.texture = preload("res://assets/graphics/card_blank_blue.svg")
		else:
			sprite.texture = preload("res://assets/graphics/card_back_red.svg")
		card_container.visible = player.is_human
		is_selectable = true
		energy_control.visible = true
		scale_up_control.visible = false
		z_index = 0
		scale = board_scale
	elif is_in_group("card_scaling"):
		if player.is_human:
			sprite.texture = preload("res://assets/graphics/card_blank_blue.svg")
		else:
			sprite.texture = preload("res://assets/graphics/card_blank_red.svg")
		card_container.visible = true
		is_selectable = false
		energy_control.visible = false
		scale_up_control.visible = true
		scale_up_control.modulate = Color.DARK_GRAY
		z_index = 16
		var target_scale: Vector2
		if is_scaling_valid:
			target_scale = board_scale + Vector2i.ONE
			is_scale_animation_increasing = false
		else:
			if scale.length_squared() > 2.5:
				is_scale_animation_increasing = false
			elif scale.length_squared() < 2.01:
				is_scale_animation_increasing = true
			if is_scale_animation_increasing:
				target_scale = Vector2(board_scale) + Vector2(0.12, 0.12)
			else:
				target_scale = board_scale
		var difference_in_scale = scale.distance_to(target_scale)
		scale = scale.move_toward(target_scale, delta * 12. * difference_in_scale)
	# movement
	var distance = global_position.distance_to(target_position)
	global_position = global_position.move_toward(target_position, delta * SPEED * distance)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_selectable and is_mouse_inside:
		clear_selectiom()
		if not player.is_human:
			user_input_failed.emit("This is not your card")
		elif player.energy < blueprint.play_cost:
			user_input_failed.emit("Not enough energy")
		else:
			add_to_group("card_selected")
			remove_from_group("card_in_hand")
		get_viewport().set_input_as_handled()


func _on_scale_up_area_pressed():
	if len(get_tree().get_nodes_in_group("card_selected")) == 0 and len(get_tree().get_nodes_in_group("card_scaling")) == 0:
		get_viewport().set_input_as_handled()
		if not player.is_human:
			user_input_failed.emit("This is not your card")
		elif player.energy < blueprint.scale_up_cost:
			user_input_failed.emit("Not enough energy")
		elif is_scaled_this_turn:
			user_input_failed.emit("Already scaled this turn")
		else:
			remove_from_group("card_on_board")
			add_to_group("card_scaling")


func clear_selectiom() -> bool:
	var result: bool = false
	for node in get_tree().get_nodes_in_group("card_selected"):
		node.remove_from_group("card_selected")
		node.add_to_group("card_in_hand")
		result = true
	for node in get_tree().get_nodes_in_group("card_scaling"):
		node.remove_from_group("card_scaling")
		node.add_to_group("card_on_board")
		result = true
	return result


func get_size():
	return sprite.texture.get_size()


func _on_mouse_entered():
	is_mouse_inside = true


func _on_mouse_exited():
	is_mouse_inside = false
