extends Sprite2D


signal arrived(target_card: Card)


var target_card: Card
var target_position: Vector2


func _ready() -> void:
	add_to_group("flame_projectile")


func _process(delta: float) -> void:
	if global_position.distance_to(target_position) < 24.:
		arrived.emit(target_card)
		queue_free()
	global_position = lerp(global_position, target_position, delta * UserSettings.animation_speed)
