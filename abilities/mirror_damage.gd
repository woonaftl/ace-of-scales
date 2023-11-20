extends HurtAbility


func use(attacker: Card, target: Card, damage: int) -> void:
	super(attacker, target, damage)
	if damage > 0:
		var projectile: Node = preload("res://scripts/damage_projectile.tscn").instantiate()
		var scene_tree: SceneTree = target.get_tree()
		scene_tree.current_scene.add_child(projectile)
		projectile.global_position = target.global_position
		projectile.attacker = target
		projectile.target = attacker
		projectile.damage = damage
		projectile.target_position = attacker.global_position
		projectile.z_index = 128
		while len(scene_tree.get_nodes_in_group("projectile")):
			await scene_tree.create_timer(0.01).timeout
