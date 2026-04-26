extends Area2D
class_name Site

signal interacted

const label_shown_pos := Vector2(-39, -40)
const label_hidden_pos := Vector2(-39, -24)

@onready var label = $Label

var tween: Tween

func _ready():
	collision_layer = 3

func enable():
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func disable():
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	end_tween()
	label.position = label_hidden_pos
	label.modulate = Color.TRANSPARENT
	label.hide()

func end_tween():
	if tween != null:
		tween.kill()
		tween = null

func hide_label():
	end_tween()
	tween = create_tween()
	tween.tween_property(label, "position", label_hidden_pos, 0.3)
	tween.parallel().tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.3)
	tween.finished.connect(func():
		label.hide()
	)
	
func show_label():
	end_tween()
	label.show()
	tween = create_tween()
	tween.tween_property(label, "position", label_shown_pos, 0.3)
	tween.parallel().tween_property(label, "modulate", Color.WHITE, 0.3)

func interact():
	interacted.emit()
