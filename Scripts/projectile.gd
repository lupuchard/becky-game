extends StaticBody2D
class_name Projectile

const player_bullet_sounds = [
	preload("res://Assets/Sound/player_bullet_01.ogg"),
	preload("res://Assets/Sound/player_bullet_02.ogg"),
	preload("res://Assets/Sound/player_bullet_03.ogg"),
]

var enemy: bool = false
var size: float
var velocity: Vector2
var damage: float
var lifespan: float

var bounces := 0
var already_hit: Array[Enemy]
var cold := 0.0

func _ready():
	collision_layer = 1 if enemy else 0
	collision_mask = 0 if enemy else 2
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = size / 2
	add_child(shape)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://Assets/icon.svg")
	sprite.scale = Vector2.ONE * size / 128.0
	sprite.look_at(global_position + velocity)
	add_child(sprite)
	
	if enemy == false:
		var sound = AudioStreamPlayer2D.new()
		sound.global_position = self.global_position
		sound.stream = player_bullet_sounds.pick_random()
		sound.autoplay = true
		add_child(sound)

func _process(delta: float):
	lifespan -= delta
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		on_collide(collision.get_collider(), collision.get_normal())
		
	if lifespan < 0:
		die()

func on_collide(collider: Object, normal: Vector2):
	if !enemy and collider is Enemy and !already_hit.has(collider):
		collider.take_damage(damage, cold)
		if bounces > 0:
			var speed = velocity.length()
			var ri = velocity.normalized()
			velocity = (-ri - 2 * normal * (ri.dot(normal))).normalized() * speed
			global_position += velocity * 0.01
			bounces -= 1
			already_hit.push_back(collider)
		else:
			die()

func die():
	queue_free()
