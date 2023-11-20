extends Sprite2D


var attacker: Card
var target: Card
var damage: int
var target_position: Vector2


func _ready() -> void:
	add_to_group("projectile")


func _process(delta: float) -> void:
	if global_position.distance_to(target_position) < 24.:
		target.hit_points -= damage
		if target.blueprint.hurt_ability != null:
			target.blueprint.hurt_ability.use(attacker, target, damage)
		queue_free()
	global_position = lerp(global_position, target_position, delta * UserSettings.animation_speed)
