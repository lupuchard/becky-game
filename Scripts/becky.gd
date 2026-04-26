extends Area2D
class_name Becky

const MAX_HEALTH := 100.0
const INV_COOLDOWN := 0.5

const MAX_SPEED := 150.0
const ACCEL := 700.0
const SHOOT_COOLDOWN := 0.2
const FLY_TRANSITION_TIME := 0.3
const FLY_SPEEDUP := 2.0

@onready var sprite = $Sprite
@onready var small_area = $SmallArea

var health := MAX_HEALTH
var vel := Vector2.ZERO
var shoot_dir := Vector2.ZERO
var shoot_cooldown := 0.0
var damage_tween: Tween
var inv_cooldown := 0.0

var flying = 0.0

var money: Array[int] = [0, 0]

var cur_site: Site = null

func _ready():
	add_to_group("becky")
	collision_mask = 1 | 2 | 3
	area_entered.connect(on_enter_area)
	area_exited.connect(on_exit_area)
	
func _input(event: InputEvent):
	if event.is_action_pressed("interact") and cur_site != null:
		cur_site.interact()

func _process(delta: float):
	if Input.is_action_pressed("fly"):
		flying = move_toward(flying, 1.0, delta / FLY_TRANSITION_TIME)
	else:
		flying = move_toward(flying, 0.0, delta / FLY_TRANSITION_TIME)
	scale = Vector2.ONE * lerp(1.0, 1.2, flying)
	z_index = 3 if flying > 0.5 else 1
	
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
	
	var target_vel: Vector2
	if Input.is_action_pressed("move_right"):
		target_vel.x = 1.0
	elif Input.is_action_pressed("move_left"):
		target_vel.x = -1.0
	else:
		target_vel.x = 0.0
	
	if Input.is_action_pressed("move_down"):
		target_vel.y = 1.0
	elif Input.is_action_pressed("move_up"):
		target_vel.y = -1.0
	else:
		target_vel.y = 0.0
	
	target_vel = target_vel.normalized() * max_speed
	vel.x = move_toward(vel.x, target_vel.x, accel * delta)
	vel.y = move_toward(vel.y, target_vel.y, accel * delta)
	
	#if vel.length() > max_speed:
	#	vel = vel.normalized() * max_speed
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
	if damage_tween != null:
		damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)

func collect(drop: Drop):
	money[drop.money_type] += drop.amount

func on_enter_area(area: Area2D):
	if area is Site:
		area.show_label()
		cur_site = area

func on_exit_area(area: Area2D):
	if area is Site:
		area.hide_label()
		if cur_site == area:
			cur_site = null

func be_thrown(dir: Vector2):
	if inv_cooldown <= 0.0:
		vel += dir * 500.0
		inv_cooldown = INV_COOLDOWN
