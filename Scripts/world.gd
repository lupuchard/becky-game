extends Node2D
class_name World

@onready var spawner: Spawner = $Spawner

func _ready():
	spawner.set_round($Rounds/Round1)
