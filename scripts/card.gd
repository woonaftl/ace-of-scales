extends Area2D


const SPEED = 8.


signal user_input_failed(message: String)


var is_mouse_inside = false
var is_selectable = false
var target_position: Vector2
var board_position: Vector2i
var hit_points: int


@onready var sprite: Sprite2D = %Sprite2D as Sprite2D
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
	if is_in_group("card_selected"):
		is_selectable = false
		energy_control.visible = true
		scale_up_control.visible = false
		z_index = 16
		rotation = 0.
	elif is_in_group("card_on_board"):
		is_selectable = false
		energy_control.visible = false
		scale_up_control.visible = true
		z_index = 0
	elif is_in_group("card_in_hand"):
		is_selectable = true
		energy_control.visible = true
		scale_up_control.visible = false
		z_index = 0
	# movement
	var distance = global_position.distance_to(target_position)
	global_position = global_position.move_toward(target_position, delta * SPEED * distance)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and is_selectable and is_mouse_inside:
		for selected_card in get_tree().get_nodes_in_group("card_selected"):
			selected_card.add_to_group("card_in_hand")
			selected_card.remove_from_group("card_selected")
		if player.energy >= blueprint.play_cost:
			add_to_group("card_selected")
			remove_from_group("card_in_hand")
		else:
			user_input_failed.emit("Not enough energy")
		get_viewport().set_input_as_handled()


func _on_scale_up_area_pressed():
	var selected_card = get_tree().get_first_node_in_group("card_selected")
	if is_instance_valid(selected_card):
		user_input_failed.emit("This place is already occupied")
		selected_card.remove_from_group("card_selected")
		selected_card.add_to_group("card_in_hand")
	else:
		if player.energy >= blueprint.scale_up_cost:
			user_input_failed.emit("Trying to scale up")
		else:
			user_input_failed.emit("Not enough energy")


func get_size():
	return sprite.texture.get_size()


func _on_mouse_entered():
	is_mouse_inside = true


func _on_mouse_exited():
	is_mouse_inside = false
