extends Resource
class_name Player


var is_human: bool = true


var energy: int = 0:
	set(new_value):
		energy = clamp(new_value, 0, 99999)
