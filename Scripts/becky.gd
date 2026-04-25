extends Area2D
class_name Becky

const MAX_HEALTH := 100.0
const INV_COOLDOWN := 0.5

const MAX_SPEED := 200.0
const ACCEL := 1000.0
const SHOOT_COOLDOWN := 0.2
const FLY_TRANSITION_TIME := 0.3
const FLY_SPEEDUP := 2.0

@onready var sprite = $Sprite

var health := MAX_HEALTH
var vel := Vector2.ZERO
var shoot_dir := Vector2.ZERO
var shoot_cooldown := 0.0
var damage_tween: Tween
var inv_cooldown := 0.0

var flying = 0.0

func _ready():
	add_to_group("becky")
	collision_mask = 1 | 2
	#body_entered.connect(on_collision)
	
func _event():
	pass

func _process(delta: float):
	if Input.is_action_pressed("fly"):
		flying = move_toward(flying, 1.0, delta / FLY_TRANSITION_TIME)
	else:
		flying = move_toward(flying, 0.0, delta / FLY_TRANSITION_TIME)
	scale = Vector2.ONE * lerp(1.0, 1.2, flying)
	
	var shooting = false
	if Input.is_action_pressed("shoot_right"):
		shooting = true
		shoot_dir.x = 1.0
	elif Input.is_action_pressed("shoot_left"):
		shooting = true
		shoot_dir.x = -1.0
	else:
		shoot_dir.x = 0.0
	
	if Input.is_action_pressed("shoot_down"):
		shooting = true
		shoot_dir.y = 1.0
	elif Input.is_action_pressed("shoot_up"):
		shooting = true
		shoot_dir.y = -1.0
	else:
		shoot_dir.y = 0.0
	
	if shoot_cooldown > 0.0:
		shoot_cooldown -= delta
	if shooting and shoot_cooldown <= 0 and flying < 0.2:
		shoot_cooldown += SHOOT_COOLDOWN
		shoot(shoot_dir.normalized())
	
	inv_cooldown = max(inv_cooldown - delta, 0.0)

func _physics_process(delta: float):
	var max_speed = lerp(MAX_SPEED, MAX_SPEED * FLY_SPEEDUP, flying)
	var accel = lerp(ACCEL, ACCEL * FLY_SPEEDUP, flying)
	
	if Input.is_action_pressed("move_right"):
		vel.x = move_toward(vel.x, max_speed, accel * delta)
	elif Input.is_action_pressed("move_left"):
		vel.x = move_toward(vel.x, -max_speed, accel * delta)
	else:
		vel.x = move_toward(vel.x, 0, accel * delta)
	
	if Input.is_action_pressed("move_down"):
		vel.y = move_toward(vel.y, max_speed, accel * delta)
	elif Input.is_action_pressed("move_up"):
		vel.y = move_toward(vel.y, -max_speed, accel * delta)
	else:
		vel.y = move_toward(vel.y, 0, accel * delta)
	
	if vel.length() > max_speed:
		vel = vel.normalized() * max_speed
	global_position += vel * delta
	
	for body in get_overlapping_bodies():
		on_collision(body)
	
func shoot(direction: Vector2):
	var proj = Projectile.new()
	proj.damage = 0.5
	proj.velocity = direction * 500.0
	proj.lifespan = 5.0
	proj.size = 20
	get_parent().add_child(proj)
	proj.global_position = global_position
	
func on_collision(body: Node2D):
	if flying >= 0.5: return
	
	if body is Enemy and inv_cooldown <= 0.0:
		take_damage(body.contact_damage)
		inv_cooldown = INV_COOLDOWN
	elif body is Projectile:
		take_damage(body.damage)
		body.die()

func take_damage(amount: float):
	health -= amount
	sprite.modulate = Color(1.0, 0.5, 0.5)
	damage_tween = create_tween()
	damage_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
