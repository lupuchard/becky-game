extends Enemy

const FLY_TRANSITION_TIME := 0.5

@export var fly_cooldown := 3.0
var fly_cooldown_remaining = 0.0
var fly_tween: Tween
var flying = 0.0

func _ready():
	target = get_tree().get_first_node_in_group("becky")
	super._ready()
	fly_cooldown_remaining = fly_cooldown

func _process(delta: float):
	super._process(delta)
	fly_cooldown_remaining -= delta
	if fly_cooldown_remaining < 0.0 and fly_tween == null:
		if flying > 0.5:
			fly_tween = create_tween()
			fly_tween.tween_property(self, "flying", 0.0, FLY_TRANSITION_TIME)
			fly_tween.finished.connect(finish_fly_transition)
			cooldown = 0.0 # projectile cooldown
			collision_layer = 2
			collision_mask = 1
		else:
			fly_tween = create_tween()
			fly_tween.tween_property(self, "flying", 1.0, Becky.FLY_TRANSITION_TIME)
			fly_tween.finished.connect(finish_fly_transition)
			cooldown = 99999.0
			collision_layer = 0
			collision_mask = 0
	
	scale = Vector2.ONE * (1.0 + flying * 0.2)
	sprite.modulate.a = (1.0 - flying + target.flying)

func finish_fly_transition():
	fly_cooldown_remaining = fly_cooldown
	fly_tween = null
