extends Sprite2D


signal arrived(player: Player)


var player: Player
var target_position: Vector2


func _ready() -> void:
	add_to_group("energy_projectile")


func _process(delta: float) -> void:
	if global_position.distance_to(target_position) < 24.:
		arrived.emit(player)
		queue_free()
	global_position = lerp(global_position, target_position, delta * UserSettings.animation_speed)
