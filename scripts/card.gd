extends Area2D
class_name Card


enum CardState {
	BOARD,
	DRAW,
	HAND,
	HAND_SELECTED,
	BOARD_SCALING,
	BOARD_SELECTED,
	DISCARD
}


signal user_input_failed(message: String)


var is_mouse_inside = false
var target_scale: Vector2
var target_rotation: float = 0.
var target_position: Vector2
var target_cell: Vector2i
var board_cell: Vector2i
var is_scale_animation_increasing: bool = true
var is_used_this_turn: bool = false
var is_scaling_valid: bool = false
var board_scale: Vector2i = Vector2i.ONE


@onready var sprite: Sprite2D = %Sprite2D as Sprite2D
@onready var face: Control = %Face as Control
@onready var hit_points_bar: TextureProgressBar = %HitPointsBar as TextureProgressBar
@onready var hit_points_label: Label = %HitPointsLabel as Label
@onready var dragon_sprite: Sprite2D = %DragonSprite as Sprite2D
@onready var name_label: Label = %NameLabel as Label
@onready var text_label: Label = %TextLabel as Label
@onready var tooltip_panel: PanelContainer = %TooltipPanel as PanelContainer
@onready var play_label: Label = %PlayLabel as Label
@onready var scale_up_label: Label = %ScaleUpLabel as Label
@onready var selection: Sprite2D = %Selection as Sprite2D
@onready var particles: GPUParticles2D = %GPUParticles2D as GPUParticles2D


@onready var player: Player:
	set(new_value):
		player = new_value
		if player.is_human:
			hit_points_bar.texture_under = preload("res://assets/graphics/hit_points_bar/human_empty.svg")
			hit_points_bar.texture_progress = preload("res://assets/graphics/hit_points_bar/human_full.svg")
		else:
			hit_points_bar.texture_under = preload("res://assets/graphics/hit_points_bar/opponent_empty.svg")
			hit_points_bar.texture_progress = preload("res://assets/graphics/hit_points_bar/opponent_full.svg")


@onready var is_damage_highlighted: bool:
	set(new_value):
		is_damage_highlighted = new_value
		if is_damage_highlighted:
			modulate = Color.LIGHT_PINK
		else:
			modulate = Color.WHITE


@onready var is_heal_highlighted: bool:
	set(new_value):
		is_heal_highlighted = new_value
		if is_heal_highlighted:
			modulate = Color.LIGHT_GREEN
		else:
			modulate = Color.WHITE


@onready var hit_points: int:
	set(new_value):
		if new_value < hit_points:
			modulate = Color.RED
			AudioBus.play("Hurt")
			await get_tree().create_timer(0.1).timeout
			modulate = Color.WHITE
		hit_points = clamp(new_value, 0, blueprint.hit_points)
		if hit_points == 0:
			if board_scale.x > 1:
				scale_down()
			else:
				discard()
		hit_points_bar.value = hit_points
		hit_points_label.text = "%s / %s" % [hit_points, blueprint.hit_points]


@onready var blueprint: Blueprint:
	set(new_value):
		blueprint = new_value
		name_label.text = blueprint.name
		text_label.text = blueprint.ability_description
		play_label.text = str(blueprint.play_cost)
		hit_points = blueprint.hit_points
		hit_points_bar.max_value = blueprint.hit_points
		dragon_sprite.texture = blueprint.texture


@onready var state: CardState:
	set(new_value):
		state = new_value
		face.visible = not (state == CardState.DRAW or state == CardState.DISCARD or (
			state == CardState.HAND and not player.is_human)
		)
		selection.visible = state == CardState.HAND_SELECTED or state == CardState.BOARD_SELECTED
		particles.restart()
		match state:
			CardState.BOARD:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/blank_human.svg")
				else:
					sprite.texture = preload("res://assets/graphics/card/blank_opponent.svg")
				z_index = 0
				target_cell = board_cell
			CardState.DRAW:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/back_human.png")
				else:
					sprite.texture = preload("res://assets/graphics/card/back_opponent.png")
				z_index = 0
				board_scale = Vector2i.ONE
				hit_points = blueprint.hit_points
				target_cell = Vector2i(-1, -1)
			CardState.DISCARD:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/back_human.png")
				else:
					sprite.texture = preload("res://assets/graphics/card/back_opponent.png")
				z_index = 0
				board_scale = Vector2i.ONE
				hit_points = blueprint.hit_points
				target_cell = Vector2i(-1, -1)
			CardState.HAND:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/blank_human.svg")
				else:
					sprite.texture = preload("res://assets/graphics/card/back_opponent.png")
				z_index = 0
				board_scale = Vector2i.ONE
				hit_points = blueprint.hit_points
				target_cell = Vector2i(-1, -1)
			CardState.HAND_SELECTED:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/blank_human.svg")
				else:
					sprite.texture = preload("res://assets/graphics/card/blank_opponent.svg")
				z_index = 16
				board_scale = Vector2i.ONE
				hit_points = blueprint.hit_points
			CardState.BOARD_SCALING:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/blank_human.svg")
				else:
					sprite.texture = preload("res://assets/graphics/card/blank_opponent.svg")
				z_index = 16
				target_cell = board_cell
			CardState.BOARD_SELECTED:
				if player.is_human:
					sprite.texture = preload("res://assets/graphics/card/blank_human.svg")
				else:
					sprite.texture = preload("res://assets/graphics/card/blank_opponent.svg")
				z_index = 16


func _ready() -> void:
	add_to_group("cards")
	user_input_failed.connect(EventBus._on_user_input_failed)


func _process(delta: float) -> void:
	scale_up_label.text = str(get_scale_up_cost())
	tooltip_panel.visible = is_mouse_inside and face.visible and len(
		QueryCard.get_cards_in_state(CardState.BOARD_SCALING)
	) == 0  and len(
		QueryCard.get_cards_in_state(CardState.BOARD_SELECTED)
	) == 0  and len(
		QueryCard.get_cards_in_state(CardState.HAND_SELECTED)
	) == 0
	match state:
		CardState.HAND_SELECTED:
			target_rotation = 0.
			target_scale = board_scale
		CardState.BOARD_SELECTED:
			target_rotation = 0.
			target_scale = board_scale
		CardState.DRAW:
			target_rotation = 0.
			target_scale = board_scale
		CardState.DISCARD:
			target_rotation = 0.
			target_scale = board_scale
		CardState.BOARD:
			target_scale = board_scale
			if is_damage_highlighted:
				target_rotation = 0.12
			elif is_heal_highlighted:
				target_rotation = -0.12
			else:
				target_rotation = 0.
		CardState.HAND:
			target_scale = board_scale
		CardState.BOARD_SCALING:
			if is_scaling_valid:
				target_scale = board_scale + Vector2i.ONE
				is_scale_animation_increasing = false
			else:
				var max_scale_extent: Vector2 = Vector2(board_scale) + Vector2(0.12, 0.12)
				if scale.length_squared() >= max_scale_extent.length_squared() - 0.01:
					is_scale_animation_increasing = false
				elif scale.length_squared() <= board_scale.length_squared() + 0.01:
					is_scale_animation_increasing = true
				if is_scale_animation_increasing:
					target_scale = max_scale_extent
				else:
					target_scale = board_scale
	rotation = lerp(rotation, target_rotation, delta * 25.)
	scale = lerp(scale, target_scale, delta * 12.)
	global_position = lerp(global_position, target_position, delta * UserSettings.animation_speed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == CardState.HAND and is_mouse_inside:
			AudioBus.play("Select")
			var new_particles: GPUParticles2D = preload("res://data/scenes/gpu_particles_2d.tscn").instantiate()
			add_child(new_particles)
			new_particles.global_position = get_global_mouse_position()
			new_particles.one_shot = true
			QueryCard.clear_selectiom()
			if get_tree().current_scene.current_turn != get_tree().current_scene.human:
				user_input_failed.emit("Not your turn")
			elif not player.is_human:
				user_input_failed.emit("This is not your card")
			elif player.energy < blueprint.play_cost:
				user_input_failed.emit("Not enough energy")
			else:
				state = CardState.HAND_SELECTED
			get_viewport().set_input_as_handled()


func _on_scale_up_area_pressed():
	if len(QueryCard.get_cards_in_state(CardState.HAND_SELECTED)) == 0:
		if len(QueryCard.get_cards_in_state(CardState.BOARD_SELECTED)) == 0:
			if len(QueryCard.get_cards_in_state(CardState.BOARD_SCALING)) == 0:
				AudioBus.play("Select")
				get_viewport().set_input_as_handled()
				if get_tree().current_scene.current_turn != get_tree().current_scene.human:
					user_input_failed.emit("Not your turn")
				elif not player.is_human:
					user_input_failed.emit("This is not your card")
				elif player.energy < get_scale_up_cost():
					user_input_failed.emit("Not enough energy")
				elif is_used_this_turn:
					user_input_failed.emit("Already played this turn")
				elif state == CardState.BOARD:
					state = CardState.BOARD_SCALING
				elif state == CardState.HAND:
					state = CardState.HAND_SELECTED


func _on_play_area_pressed() -> void:
	if len(QueryCard.get_cards_in_state(CardState.HAND_SELECTED)) == 0:
		if len(QueryCard.get_cards_in_state(CardState.BOARD_SELECTED)) == 0:
			if len(QueryCard.get_cards_in_state(CardState.BOARD_SCALING)) == 0:
				AudioBus.play("Select")
				get_viewport().set_input_as_handled()
				if get_tree().current_scene.current_turn != get_tree().current_scene.human:
					user_input_failed.emit("Not your turn")
				elif not player.is_human:
					user_input_failed.emit("This is not your card")
				elif player.energy < blueprint.play_cost:
					user_input_failed.emit("Not enough energy")
				elif is_used_this_turn:
					user_input_failed.emit("Already played this turn")
				elif state == CardState.BOARD:
					state = CardState.BOARD_SELECTED
				elif state == CardState.HAND:
					state = CardState.HAND_SELECTED


func scale_up(board_direction: Vector2i) -> void:
	AudioBus.play("ScaleUp")
	var cost: int = get_scale_up_cost()
	board_cell = Vector2i(
		min(board_direction.x, board_cell.x),
		min(board_direction.y, board_cell.y)
	)
	board_scale += Vector2i.ONE
	is_used_this_turn = true
	var overlapping_cards: Array = QueryCard.get_cards_in_rectangle(
		board_cell,
		board_scale
	)
	for overlapping_card in overlapping_cards:
		overlapping_card.board_cell = Vector2i(-1, -1)
		overlapping_card.board_scale = Vector2i.ONE
		overlapping_card.player = player
		overlapping_card.state = Card.CardState.HAND
	state = CardState.BOARD
	player.energy -= cost


func scale_down() -> void:
	AudioBus.play("ScaleDown")
	board_scale = board_scale - Vector2i.ONE
	var new_board_cells: Array = [
		board_cell,
		board_cell + Vector2i.RIGHT,
		board_cell + Vector2i.DOWN,
		board_cell + Vector2i.ONE
	]
	board_cell = new_board_cells.pick_random()
	hit_points = blueprint.hit_points


func play(new_board_cell: Vector2i) -> void:
	AudioBus.play("Play")
	state = CardState.BOARD
	is_used_this_turn = true
	board_cell = new_board_cell
	player.energy -= blueprint.play_cost
	if blueprint.play_ability != null:
		await blueprint.play_ability.use(self)
		await get_tree().current_scene.check_lose()


func reset() -> void:
	is_used_this_turn = false


func discard() -> void:
	state = CardState.DISCARD


func get_occupied_cells(cell: Vector2i = board_cell) -> Array[Vector2i]:
	return CellsHelpers.get_cells_inside_rectangle(cell, board_scale)


func get_size():
	return sprite.texture.get_size()


func get_scale_up_cost() -> int:
	if board_scale == Vector2i(1, 1):
		return blueprint.scale_up_2_cost
	elif board_scale == Vector2i(2, 2):
		return blueprint.scale_up_3_cost
	elif board_scale == Vector2i(3, 3):
		return blueprint.scale_up_4_cost
	else:
		return blueprint.scale_up_5_cost


func _on_mouse_entered():
	is_mouse_inside = true


func _on_mouse_exited():
	is_mouse_inside = false
