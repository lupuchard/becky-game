extends StaticBody2D
class_name Projectile

var size: float
var velocity: Vector2
var damage: float
var lifespan: float

func _ready():
	collision_layer = 0
	collision_mask = 2
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = size / 2
	add_child(shape)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://Assets/icon.svg")
	sprite.scale = Vector2.ONE * size / 128.0
	sprite.look_at(global_position + velocity)
	add_child(sprite)

func _process(delta: float):
	lifespan -= delta
	var collision = move_and_collide(velocity * delta)
	if collision != null and collision.get_collider() is Enemy:
		collision.get_collider().take_damage(damage)
		die()
		
	if lifespan < 0:
		die()

func on_collide():
	pass

func die():
	queue_free()
