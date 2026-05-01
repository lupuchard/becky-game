extends StaticBody2D
class_name Projectile

@onready var shoot_sound: AudioStreamPlayer2D = get_node_or_null("ShootSound")
@onready var hit_sound: AudioStreamPlayer2D = get_node_or_null("HitSound")

var velocity: Vector2
@export var enemy: bool = false
@export var damage: float
@export var lifespan: float

var already_hit: Array[Enemy]
@export var bounces := 0
@export var cold := 0.0
@export var lifesteal := 0

func _ready():
	collision_layer = 1 if enemy else 0
	collision_mask = 0 if enemy else 2
	
	if shoot_sound != null:
		shoot_sound.play()

func _process(delta: float):
	lifespan -= delta
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		on_collide(collision.get_collider(), collision.get_normal())
		
	if lifespan < 0:
		die()

func on_collide(_collider: Object, _normal: Vector2):
	pass

func die():
	if hit_sound != null and hit_sound.playing:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
		hit_sound.process_mode = Node.PROCESS_MODE_ALWAYS
		hit_sound.finished.connect(queue_free)
	else:
		queue_free()
