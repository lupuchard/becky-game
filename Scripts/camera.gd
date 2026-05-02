extends Camera2D

const FLYING_ZOOM = 0.8
const FLYING_FOG_DENSITY = 0.1

@onready var fog = $Fog

@export var becky: Becky
@export var bounds_node: Marker2D
var bounds: Vector2

func _ready():
	add_to_group("camera")
	bounds = bounds_node.global_position
	fog.visible = true

func _process(_delta: float):
	zoom = Vector2.ONE * lerp(1.0, FLYING_ZOOM, becky.flying)
	fog.modulate = Color(1.0, 1.0, 1.0, becky.flying * FLYING_FOG_DENSITY)
	
	var view_size = get_viewport().get_visible_rect().size / zoom
	global_position.x = clamp(
		becky.global_position.x,
		0.0 + view_size.x / 2.0,
		bounds.x - view_size.x / 2.0
	)
	
	global_position.y = clamp(
		becky.global_position.y,
		0.0 + view_size.y / 2,
		bounds.y - view_size.y / 2
	)

func get_bounds() -> Rect2:
	var rect = get_viewport().get_visible_rect()
	var size = rect.size / zoom
	rect.position = global_position - size * 0.5
	rect.size = size
	return rect
