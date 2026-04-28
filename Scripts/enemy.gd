extends StaticBody2D
class_name Enemy

const LIFESTEAL_DROP = preload("res://Drops/Drop3.tscn")
const ARROW_MARGIN := 10
const COLD_DECAY := 0.1
const MAX_COLD := 1.5

signal died
signal reached_end

@onready var sprite: Sprite2D = $Sprite
@onready var oob_arrow: Sprite2D = Sprite2D.new()
@onready var camera: Camera2D = get_viewport().get_camera_2d()

@export var health: float = 1.0
@export var max_speed: float = 1.0
@export var accel: float = 10.0
@export var contact_damage: float = 10.0

@export var projectile_damage: float = 0.0
@export var projectile_cooldown: float = 0.0

@export var possible_paths: Array[Path2D]
@export var drops: Dictionary[PackedScene, float] = {}

var target: Node2D

var path0: Curve2D
var path1: Curve2D
var path_preference: float = 0.0
var path_distance: float = 0.0
var path_length: float = 0.0
var speed: float = 0.0
var going_back: bool = false

var cooldown: float = 0.0

var cold := 0.0

var damage_tween: Tween
var is_dead := false

func _ready():
	collision_layer = 2
	collision_mask = 1
	
	cooldown = projectile_cooldown
	
	if possible_paths.size() > 0:
		pick_random_path()
	
	target = get_tree().get_first_node_in_group("becky")
	
	oob_arrow.hide()
	oob_arrow.texture = preload("res://Assets/arrow.png")
	add_child(oob_arrow)

func _process(delta: float):
	if is_dead: return
	
	if path0 != null:
		speed = min(speed + accel * delta, max_speed) / (cold + 1.0)
		path_distance += speed * delta
		if path_distance >= path_length:
			if going_back:
				reach_end()
			else:
				speed = 0.0
				going_back = true
				oob_arrow.modulate = Color.ORANGE
				pick_random_path()
		else:
			update_position()
	
	if projectile_cooldown > 0.0 and projectile_damage > 0.0:
		cooldown -= delta
		if cooldown <= 0.0:
			cooldown += projectile_cooldown
			shoot_projectile()
	
	cold = clamp(0, cold - COLD_DECAY * delta, MAX_COLD)
	modulate = Color(1 / (cold + 1), 1 / (cold + 1), 1.0)
	
	var bounds: Rect2 = camera.get_bounds()
	if global_position.x > bounds.end.x:
		oob_arrow.show()
		if global_position.y > bounds.end.y:
			oob_arrow.rotation = (PI / 4) * 3
			oob_arrow.global_position = bounds.end + Vector2(-ARROW_MARGIN, -ARROW_MARGIN)
		elif global_position.y < bounds.position.y:
			oob_arrow.rotation = (PI / 4) * 1
			oob_arrow.global_position = bounds.end + Vector2(-ARROW_MARGIN, ARROW_MARGIN)
		else:
			oob_arrow.rotation = (PI / 2) * 1
			oob_arrow.position.y = 0.0
			oob_arrow.global_position.x = bounds.end.x - ARROW_MARGIN
	elif global_position.x < bounds.position.x:
		oob_arrow.show()
		if global_position.y > bounds.end.y:
			oob_arrow.rotation = (PI / 4) * 5
			oob_arrow.global_position = bounds.end + Vector2(-ARROW_MARGIN, -ARROW_MARGIN)
		elif global_position.y < bounds.position.y:
			oob_arrow.rotation = (PI / 4) * 7
			oob_arrow.global_position = bounds.end + Vector2(-ARROW_MARGIN, ARROW_MARGIN)
		else:
			oob_arrow.rotation = (PI / 2) * 3
			oob_arrow.position.y = 0.0
			oob_arrow.global_position.x = bounds.position.x + ARROW_MARGIN
	elif global_position.y > bounds.end.y:
		oob_arrow.show()
		oob_arrow.rotation = PI
		oob_arrow.position.x = 0.0
		oob_arrow.global_position.y = bounds.end.y - ARROW_MARGIN
	elif global_position.y < bounds.position.y:
		oob_arrow.rotation = 0
		oob_arrow.show()
		oob_arrow.position.x = 0.0
		oob_arrow.global_position.y = bounds.position.y + ARROW_MARGIN
	else:
		oob_arrow.hide()

func shoot_projectile():
	if target.flying > 0.5:
		return
	var proj = Projectile.new()
	proj.damage = projectile_damage
	proj.velocity = (target.global_position - global_position).normalized() * 200.0
	proj.lifespan = 60.0
	proj.size = 10
	proj.enemy = true
	get_parent().add_child(proj)
	proj.global_position = global_position

func pick_random_path():
	if possible_paths.size() == 1:
		path0 = possible_paths[0].curve
		path1 = possible_paths[0].curve
	elif possible_paths.size() == 2:
		path0 = possible_paths[0].curve
		path1 = possible_paths[1].curve
	else:
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

func take_damage(damage: float, cold_damage: float = 0.0, lifesteal: int = 0):
	health -= damage
	if health <= 0:
		die(lifesteal)
	else:
		sprite.modulate = Color(1.0, 0.5, 0.5)
		if damage_tween != null:
			damage_tween.kill()
		damage_tween = create_tween()
		damage_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
		
		cold += cold_damage

func die(lifesteal: int):
	if is_dead: return
	collision_layer = 0
	collision_mask = 0
	sprite.modulate = Color(1.0, 0.0, 0.0)
	
	for drop in drops.keys():
		var amount = drops[drop]
		for i in range(0, floor(amount)):
			spawn_drop(drop)
		var remainder = fmod(amount, 1.0)
		if remainder >= 0.01 and randf() < remainder:
			spawn_drop(drop)
	
	if lifesteal > 0:
		var lifesteal_drop = spawn_drop(LIFESTEAL_DROP)
		lifesteal_drop.amount = lifesteal
	
	if damage_tween != null:
		damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_property(sprite, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.3)
	damage_tween.finished.connect(func():
		queue_free()
	)
	died.emit()
	
	is_dead = true

func reach_end():
	reached_end.emit()
	queue_free()

func spawn_drop(drop_scene: PackedScene) -> Drop:
	var drop = drop_scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = global_position
	return drop
