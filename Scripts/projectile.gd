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
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		on_collide(collision.get_collider())
		
	if lifespan < 0:
		die()

func on_collide(collider: Object):
	if !enemy and collider is Enemy:
		collider.take_damage(damage)
		die()

func die():
	queue_free()
