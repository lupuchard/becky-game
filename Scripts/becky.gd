extends Area2D
class_name Becky

enum Upgrade {
	RAPID_SHOT,
	DOUBLE_SHOT,
	COLD_SHOT,
	BOUNCE_SHOT,
	SHIELD,
	LIFESTEAL,
	TOTAL,
}

const PROJECTILE = preload("res://Projectiles/PlayerProjectile.tscn")

const MAX_HEALTH := 100.0
const MAX_SHIELD_HEALTH := 25.0
const SHIELD_REGEN := 5.0
const INV_COOLDOWN := 0.5

const MAX_SPEED := 200.0
const ACCEL := 800.0
const SHOOT_COOLDOWN := 0.2
const RAPID_SHOT_COOLDOWN := 0.15
const DOUBLE_SHOT_COOLDOWN_MOD := 1.5
const FLY_TRANSITION_TIME := 0.3
const FLY_SPEEDUP := 2.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var small_area: Area2D = $SmallArea
@onready var shield: Area2D = $Shield
@onready var upgrade_sound: AudioStreamPlayer2D = $UpgradeSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

var health := MAX_HEALTH
var shield_health := MAX_SHIELD_HEALTH
var vel := Vector2.ZERO
var last_shoot_dir := Vector2.ZERO
var shoot_cooldown := 0.0
var damage_tween: Tween
var inv_cooldown := 0.0

var flying = 0.0

var money: Array[int]
var upgrades: Array[bool] = []

var initial_position: Vector2
var cur_site: Site = null

func _ready():
	add_to_group("becky")
	collision_mask = 1 | 2 | 3
	area_entered.connect(on_enter_area)
	area_exited.connect(on_exit_area)
	initial_position = global_position
	shield.collision_mask = 1
	reset()

func _process(delta: float):
	if Input.is_action_pressed("fly"):
		flying = move_toward(flying, 1.0, delta / FLY_TRANSITION_TIME)
	else:
		flying = move_toward(flying, 0.0, delta / FLY_TRANSITION_TIME)
	scale = Vector2.ONE * lerp(1.0, 1.2, flying)
	z_index = 3 if flying > 0.5 else 1
	
	if Input.is_action_pressed("interact") and cur_site != null:
		cur_site.pressing(delta, false)
	elif Input.is_action_pressed("interact_alt") and cur_site != null:
		cur_site.pressing(delta, true)
	
	var shooting := false
	var shoot_dir := Vector2.ZERO
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
	
	if shooting:
		last_shoot_dir = shoot_dir
	
	if shoot_cooldown > 0.0:
		shoot_cooldown -= delta
	if shooting and shoot_cooldown <= 0 and flying < 0.2:
		shoot_cooldown += RAPID_SHOT_COOLDOWN if upgrades[Upgrade.RAPID_SHOT] else SHOOT_COOLDOWN
		var dir = shoot_dir.normalized()
		if upgrades[Upgrade.DOUBLE_SHOT]:
			shoot(dir, dir.orthogonal() * 10.0)
			shoot(dir, -dir.orthogonal() * 10.0)
			shoot_cooldown *= DOUBLE_SHOT_COOLDOWN_MOD
		else:
			shoot(dir, Vector2.ZERO)
	
	inv_cooldown = max(inv_cooldown - delta, 0.0)
	
	if upgrades[Upgrade.SHIELD]:
		update_shield_direction(last_shoot_dir, delta)

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
	
	if vel != Vector2.ZERO:
		#if vel.length() > max_speed:
		#	vel = vel.normalized() * max_speed
		global_position += vel * delta
		sprite.flip_h = vel.x < 0
	
	if upgrades[Upgrade.SHIELD]:
		shield.modulate = Color(1.0, 1.0, 1.0, shield_health / MAX_SHIELD_HEALTH)
		if shield_health > 0.0:
			shield_health = min(shield_health + SHIELD_REGEN * delta, MAX_SHIELD_HEALTH)
		if flying < 0.5:
			for body in shield.get_overlapping_bodies():
				on_shield_collision(body)
	
	if flying < 0.5:
		for body in get_overlapping_bodies():
			on_collision(body)
	
func shoot(direction: Vector2, offset: Vector2):
	var proj = PROJECTILE.instantiate()
	proj.velocity = direction * 500.0
	proj.global_position = global_position + offset
	get_parent().add_child(proj)
	
	if upgrades[Upgrade.COLD_SHOT]:
		proj.cold += 0.2
	
	if upgrades[Upgrade.BOUNCE_SHOT]:
		proj.bounces = 3
	
	if upgrades[Upgrade.LIFESTEAL]:
		proj.lifesteal = 5
	
func on_collision(body: Node2D):
	if flying >= 0.5: return
	
	if body is Enemy and inv_cooldown <= 0.0:
		take_damage(body.contact_damage)
		inv_cooldown = INV_COOLDOWN
	elif body is Projectile:
		take_damage(body.damage)
		body.die()

func on_shield_collision(body: Node2D):
	if flying >= 0.5: return
	
	if body is Projectile and shield_health >= 0:
		shield_health -= body.damage
		body.die()

func take_damage(amount: float):
	health -= amount
	if damage_tween != null:
		damage_tween.kill()
	
	if health > 0.0:
		sprite.modulate = Color(1.0, 0.5, 0.5)
		damage_tween = create_tween()
		damage_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
		hurt_sound.play()

func collect(money_type: int, amount: int):
	if money_type == -1:
		health = min(health + amount, MAX_HEALTH)
	else:
		money[money_type] += amount

func on_enter_area(area: Area2D):
	if area is Site:
		area.show_label()
		cur_site = area

func on_exit_area(area: Area2D):
	if area is Site:
		area.hide_label()
		if cur_site == area:
			cur_site = null

func be_thrown(dir: Vector2, damage: float):
	if inv_cooldown <= 0.0:
		vel += dir * 500.0
		take_damage(damage)

func apply_upgrade(upgrade: Upgrade):
	upgrades[upgrade] = true
	upgrade_sound.play()
	
	if upgrade == Upgrade.SHIELD:
		shield.show()
		shield.process_mode = Node.PROCESS_MODE_INHERIT

func reset():
	money = [0, 0]
	upgrades.resize(Upgrade.TOTAL)
	upgrades.fill(false)
	vel = Vector2.ZERO
	global_position = initial_position
	health = MAX_HEALTH
	flying = 0
	
	shield.hide()
	shield.process_mode = Node.PROCESS_MODE_DISABLED

func update_shield_direction(dir: Vector2, delta: float):
	if dir == Vector2.ZERO: return
	var target = Vector2.UP.angle_to(dir)
	shield.rotation = lerp_angle(shield.rotation, target, 3.0 * delta)
