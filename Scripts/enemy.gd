extends StaticBody2D
class_name Enemy

@onready var sprite: Sprite2D = $Sprite

@export var health: float = 1.0
@export var max_speed: float = 1.0
@export var accel: float = 10.0

@export var possible_paths: Array[Path2D]

var path0: Curve2D
var path1: Curve2D
var path_preference: float = 0.0
var path_distance: float = 0.0
var path_length: float = 0.0
var speed: float = 0.0
var going_back: bool = false

var damage_tween: Tween

func _ready():
	collision_layer = 2
	collision_mask = 1
	
	if possible_paths.size() > 0:
		pick_random_path()

func _process(delta: float):
	if is_dead() || path0 == null: return
	
	speed = min(speed + accel * delta, max_speed)
	path_distance += speed * delta
	if path_distance >= path_length:
		if going_back:
			die()
		else:
			speed = 0.0
			going_back = true
			pick_random_path()
	else:
		update_position()

func pick_random_path():
	path0 = possible_paths.pick_random().curve
	for i in range(0, 3):
		path1 = possible_paths.pick_random().curve
		if path1 != path0:
			break
	path_preference = randf()
	path_length = lerp(path0.get_baked_length(), path1.get_baked_length(), path_preference)
	path_distance = 0.0
	update_position()

func update_position():
	var dist = path_distance / path_length
	if going_back: dist = 1.0 - dist
	var point1 = path0.sample_baked(dist * path0.get_baked_length())
	var point2 = path1.sample_baked(dist * path1.get_baked_length())
	global_position = lerp(point1, point2, path_preference)

func take_damage(damage: float):
	health -= damage
	if is_dead():
		die()
	else:
		sprite.modulate = Color(1.0, 0.5, 0.5)
		damage_tween = create_tween()
		damage_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)

func die():
	collision_layer = 0
	collision_mask = 0
	sprite.modulate = Color(1.0, 0.0, 0.0)
	damage_tween = create_tween()
	damage_tween.tween_property(sprite, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.3)

func is_dead():
	return health <= 0
