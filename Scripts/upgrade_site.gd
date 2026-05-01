extends Site
class_name UpgradeSite

const money_colors = ["darkturquoise", "orange"]

@onready var cant_afford_label = $CantAffordLabel

@export var upgrade1: Becky.Upgrade
@export var upgrade1_name: String
@export var upgrade2: Becky.Upgrade
@export var upgrade2_name: String
@export var cost: int = 0
@export var cost_type: int = 0

var upgrade1_got := false
var upgrade2_got := false

func _ready():
	super._ready()
	interacted.connect(on_interact)
	cant_afford_label.modulate = Color.TRANSPARENT
	update()

func enable():
	update()
	if !(upgrade1_got and upgrade2_got):
		super.enable()

func on_interact(alt):
	var upgrade = upgrade1 if alt else upgrade2
	var becky: Becky = get_tree().get_first_node_in_group("becky")
	
	if becky.money[cost_type] < get_cost():
		cant_afford_label.modulate = Color.WHITE
		var cant_afford_tween = create_tween()
		cant_afford_tween.tween_property(cant_afford_label, "modulate", Color.TRANSPARENT, 1.0)
		return
	
	if becky.upgrades[upgrade]:
		return
	
	becky.money[cost_type] -= get_cost()
	becky.apply_upgrade(upgrade)
	update()

func update():
	var becky: Becky = get_tree().get_first_node_in_group("becky")
	upgrade1_got = becky.upgrades[upgrade1]
	upgrade2_got = becky.upgrades[upgrade2]
	
	progress_bar.visible = !upgrade2_got
	progress_bar_alt.visible = !upgrade1_got
	
	if upgrade1_got and upgrade2_got:
		disable()
	else:
		label.text = "[color=%s]Cost %s[/color]\n" % [money_colors[cost_type], get_cost()]
		if !upgrade1_got: label.text += "Hold Q or (A) for %s" % upgrade1_name
		if !upgrade2_got: label.text += "\nHold E or (B) for %s" % upgrade2_name

func get_cost():
	return cost if (!upgrade1_got and !upgrade2_got) else cost * 3
