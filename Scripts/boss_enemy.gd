extends PulseEnemy

const SPRAY_COOLDOWN = 10.0
const CARDINAL_COOLDOWN = 4.0

var spray_cooldown := 4.0
var cardinal_cooldown := 2.0

func _ready():
	super._ready()
	PULSE_COOLDOWN = 8.0
	pulse_cooldown = PULSE_COOLDOWN

func _process(delta: float):
	super._process(delta)
	
	spray_cooldown -= delta
	if spray_cooldown <= 0:
		do_spray()
		spray_cooldown += SPRAY_COOLDOWN
		
	cardinal_cooldown -= delta
	if cardinal_cooldown <= 0:
		do_cardinal()
		cardinal_cooldown += CARDINAL_COOLDOWN
	
	cold = clamp(0, cold - COLD_DECAY * delta * 10.0, MAX_COLD / 4.0)

func do_spray():
	var tween = create_tween()
	var angle = 0.0
	for i in range(0, 30):
		var dir = Vector2.from_angle(angle)
		tween.tween_callback(func():
			shoot_projectile_dir(dir)
		).set_delay(0.1)
		angle += PI * 2.0 / 30.0
		

func do_cardinal():
	shoot_projectile_dir(Vector2(1.0, 1.0).normalized())
	shoot_projectile_dir(Vector2(1.0, 0.0))
	shoot_projectile_dir(Vector2(1.0, -1.0).normalized())
	shoot_projectile_dir(Vector2(-1.0, 1.0).normalized())
	shoot_projectile_dir(Vector2(-1.0, 0.0))
	shoot_projectile_dir(Vector2(-1.0, -1.0).normalized())
	shoot_projectile_dir(Vector2(0.0, 1.0))
	shoot_projectile_dir(Vector2(0.0, -1.0))

func shoot_projectile_dir(dir: Vector2):
	var proj = PROJECTILE.instantiate()
	proj.damage = damage
	proj.velocity = dir * 200.0
	proj.lifespan = 60.0
	proj.global_position = global_position
	get_parent().add_child(proj)
