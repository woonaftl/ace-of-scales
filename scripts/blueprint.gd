extends Resource
class_name Blueprint


@export var name: String
@export var texture: Texture2D
@export var hit_points: int
@export_category("Abilities")
@export_multiline var ability_description: String
@export var hurt_ability: HurtAbility
@export var play_ability: PlayAbility
@export var turn_ability: TurnAbility
@export_category("Cost")
@export var play_cost: int
@export var scale_up_2_cost: int
@export var scale_up_3_cost: int
@export var scale_up_4_cost: int
@export var scale_up_5_cost: int
