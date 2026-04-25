extends StaticBody2D
class_name Enemy

@export var health: float = 1.0

func _ready():
	collision_layer = 2
	collision_mask = 1

func _process(delta: float):
	pass

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()
