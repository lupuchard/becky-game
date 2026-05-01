extends Node2D
class_name Drop

const STARTING_VEL_SLOWDOWN := 100.0
const ACCEL := 150.0
const ACCEL2 := 1.0

@export var money_type: int = 0
@export var amount: int = 5
var becky: Node
var starting_vel: Vector2
var speed: float = 0.0

func _ready():
	becky = get_tree().get_first_node_in_group("becky")
	starting_vel = Vector2(randf(), randf()) * 100.0

func _process(delta: float):
	starting_vel.x = move_toward(starting_vel.x, 0.0, STARTING_VEL_SLOWDOWN * delta)
	starting_vel.y = move_toward(starting_vel.y, 0.0, STARTING_VEL_SLOWDOWN * delta)
	global_position += starting_vel * delta
	
	speed += delta * ACCEL + speed * delta * ACCEL2
	var disp = becky.global_position - global_position
	if disp.length_squared() < pow(speed * delta, 2):
		be_collected()
	else:
		global_position += disp.normalized() * speed * delta

func be_collected():
	becky.collect(money_type, amount)
	queue_free()
