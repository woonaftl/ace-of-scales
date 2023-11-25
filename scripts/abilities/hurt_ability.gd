extends Resource
class_name HurtAbility


func use(_attacker: Card, target: Card, _damage: int) -> void:
	await target.get_tree().create_timer(0.01).timeout
	pass
