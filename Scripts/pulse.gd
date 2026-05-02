extends Node2D
class_name Pulse

@onready var ripple: MeshInstance2D = $Ripple

var collision_done = false
@onready var inner: Area2D = $Inner
@onready var inner_circle: CollisionShape2D = $Inner/Shape
@onready var outer: Area2D = $Outer
@onready var outer_circle: CollisionShape2D = $Outer/Shape

var becky: Becky
var damage: float
var time := 0.0

func _ready():
	becky = get_tree().get_first_node_in_group("becky")
	ripple.material = ripple.material.duplicate()
	ripple.material.set_shader_parameter("time", time)

func _process(delta: float):
	time += delta * 3.0
	ripple.material.set_shader_parameter("time", time)
	
	if !collision_done:
		if time < 1.0:
			inner_circle.scale = Vector2.ONE * lerp(0.1, 2.2, time)
			outer_circle.scale = Vector2.ONE * lerp(0.2, 5.0, time)
		elif time < 2.0:
			inner_circle.scale = Vector2.ONE * lerp(2.2, 7.6, time - 1.0)
			outer_circle.scale = Vector2.ONE * lerp(5.0, 10.2, time - 1.0)
		elif time < 4.0:
			inner_circle.scale = Vector2.ONE * lerp(7.6, 18.5, (time - 2.0) / 2.0)
			outer_circle.scale = Vector2.ONE * lerp(10.2, 21.0, (time - 2.0) / 2.0)
		elif time < 8.0:
			inner_circle.scale = Vector2.ONE * lerp(18.5, 40.0, (time - 4.0) / 4.0)
			outer_circle.scale = Vector2.ONE * lerp(21.0, 41.0, (time - 4.0) / 4.0)
		else:
			collision_done = true
			inner_circle.queue_free()
			outer_circle.queue_free()
	
	if (!collision_done
		and becky.flying < 0.5
		and outer.overlaps_area(becky.small_area)
		and !inner.overlaps_area(becky.small_area)
	):
		throw_becky()
	
	if time >= 16.0:
		queue_free()

func throw_becky():
	becky.be_thrown((becky.global_position - global_position).normalized(), damage)
