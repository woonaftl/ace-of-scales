extends TurnAbility


func use(card: Card) -> void:
	super(card)
	var projectile = preload("res://data/scenes/energy_projectile.tscn").instantiate()
	var current_scene = card.get_tree().current_scene
	current_scene.add_child(projectile)
	projectile.global_position = card.global_position
	projectile.scale = Vector2(0.2, 0.2)
	projectile.player = card.player
	if card.player.is_human:
		projectile.texture = preload("res://assets/graphics/energy.svg")
		projectile.target_position = current_scene.human_energy_control.global_position + Vector2(64., 64.)
	else:
		projectile.texture = preload("res://assets/graphics/energy_opponent.svg")
		projectile.target_position = current_scene.opponent_energy_control.global_position + Vector2(64., 64.)
	projectile.z_index = 128
