extends Enemy

const PULSE_COOLDOWN := 5.0
const PULSE = preload("res://Enemies/Pulse.tscn")

var pulse_cooldown = 2.0

func _process(delta: float):
	pulse_cooldown -= delta
	if pulse_cooldown <= 0:
		pulse_cooldown += PULSE_COOLDOWN
		create_pulse()
	super._process(delta)
	
func create_pulse():
	var pulse: Pulse = PULSE.instantiate()
	pulse.global_position = global_position
	pulse.scale = Vector2.ONE * 2.0
	pulse.damage = damage
	get_parent().add_child(pulse)
