extends Node2D
class_name World

@onready var becky: Becky = $Becky
@onready var spawner: Spawner = $Spawner

@onready var round_label: Label = $CanvasLayer/RoundProgress/Label
@onready var time_progress: ProgressBar = $CanvasLayer/RoundProgress/TimeProgress
@onready var kill_progress: ProgressBar = $CanvasLayer/RoundProgress/KillProgress

@onready var health_bar: ProgressBar = $CanvasLayer/Status/HealthBar

@onready var game_over_panel: Control = $CanvasLayer/GameOverPanel
@onready var retry_button: Button = $CanvasLayer/GameOverPanel/Container/Buttons/RetryButton

@onready var resource1: Label = $CanvasLayer/Resources/Container/Resource1
@onready var resource2: Label = $CanvasLayer/Resources/Container/Resource2

@onready var rounds: Node = $Rounds
@onready var next_round_site: Site = $NextRound

var current_round := 0
var between_rounds := false

func _ready():
	spawner.set_round($Rounds/Round1)
	retry_button.pressed.connect(reset)
	game_over_panel.hide()
	
	next_round_site.disable()
	next_round_site.interacted.connect(start_next_round)
	spawner.round_ended.connect(on_round_ended)

func _process(_delta: float):
	time_progress.value = spawner.round_current_time / spawner.round_total_time
	kill_progress.value = float(spawner.round_dead_enemies) / spawner.round_total_enemies
	health_bar.value = becky.health / Becky.MAX_HEALTH
	
	if becky.health <= 0.0:
		game_over()
	
	resource1.text = "Placeholder 1: " + str(becky.money[0])
	resource2.text = "Placeholder 2: " + str(becky.money[1])

func game_over():
	game_over_panel.show()
	becky.process_mode = Node.PROCESS_MODE_DISABLED
	becky.hide()

func reset():
	game_over_panel.hide()
	becky.health = Becky.MAX_HEALTH
	for child in get_children():
		if child is Enemy or child is Projectile:
			child.queue_free()
	spawner.set_round($Rounds/Round1)
	
	becky.show()
	becky.process_mode = Node.PROCESS_MODE_INHERIT
	current_round = 0
	between_rounds = false
	
func on_round_ended():
	next_round_site.enable()
	between_rounds = true
	current_round += 1

func start_next_round():
	if between_rounds and current_round < rounds.get_child_count():
		spawner.set_round($Rounds.get_child(current_round))
		next_round_site.disable()
		
