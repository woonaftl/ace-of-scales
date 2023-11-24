extends Sprite2D


var attacker: Card
var target: Card
var damage: int
var target_position: Vector2
var is_push: bool = false
var is_transfer: bool = false


func _ready() -> void:
	add_to_group("projectile")


func _process(delta: float) -> void:
	if global_position.distance_to(target_position) < 24.:
		target.hit_points -= damage
		if is_push:
			var new_board_cell = 2 * target.board_cell - attacker.board_cell
			if target.get_tree().current_scene.tile_map.is_cell_vacant(new_board_cell):
				target.board_cell = new_board_cell
		if is_transfer:
			var cards_to_heal: Array[Card] = QueryCard.get_cards_in_cells(
				CellsHelpers.get_cells_adjacent_to_rectangle(
					target.board_cell,
					target.board_scale
				)
			).filter(
				func(affected_card: Card):
					return affected_card.player == attacker.player and \
						affected_card.hit_points < affected_card.blueprint.hit_points
			)
			if len(cards_to_heal) > 0:
				var healed_card = cards_to_heal.pick_random()
				var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
				get_tree().current_scene.add_child(projectile)
				projectile.global_position = target.global_position
				projectile.attacker = target
				projectile.target = healed_card
				projectile.damage = -damage
				projectile.target_position = healed_card.global_position
				projectile.z_index = 128
		if target.blueprint.hurt_ability != null:
			target.blueprint.hurt_ability.use(attacker, target, damage)
		queue_free()
	global_position = lerp(global_position, target_position, delta * UserSettings.animation_speed)
