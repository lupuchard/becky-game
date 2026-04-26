extends Site
class_name UpgradeSite

@export var upgrade1: Becky.Upgrade
@export var upgrade2: Becky.Upgrade
@export var cost: int = 0
@export var cost_type: int = 0

func _ready():
	super._ready()
	interacted.connect(on_interact)

func enable():
	var becky: Becky = get_tree().get_first_node_in_group("becky")
	if !becky.upgrades[upgrade1] and !becky.upgrades[upgrade2]:
		super.enable()

func on_interact(alt):
	var becky: Becky = get_tree().get_first_node_in_group("becky")
	if becky.money[cost_type] < cost:
		return
	
	becky.money[cost_type] -= cost
	becky.apply_upgrade(upgrade1 if alt else upgrade2)
	disable()
	
