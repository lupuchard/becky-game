extends Area2D
class_name Site

signal interacted(alt: bool)

var label_shown_pos: Vector2
var label_hidden_pos: Vector2

@onready var label = $Label
@onready var progress_bar = $ProgressBar
@onready var progress_bar_alt = get_node_or_null("ProgressBarAlt")

var tween: Tween
var interact_wait := 0.0
var interact_alt := false

func _ready():
	label_shown_pos = label.position
	label_hidden_pos = label.position + Vector2(0, 16)
	collision_layer = 3
	label.hide()

func _process(delta: float):
	interact_wait = max(0.0, interact_wait - delta * 2.0)
	
	if interact_alt and progress_bar_alt != null:
		progress_bar_alt.value = interact_wait
		progress_bar.value = 0.0
	elif !interact_alt:
		progress_bar.value = interact_wait
		if progress_bar_alt != null:
			progress_bar_alt.value = 0.0

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

func pressing(delta: float, alt: bool):
	if interact_alt != alt:
		interact_alt = alt
		interact_wait = 0.0
	
	interact_wait += delta * 3.0
	if interact_wait >= 1.0:
		interact_wait = 0.0
		interacted.emit(interact_alt)
