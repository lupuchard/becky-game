extends Node2D
class_name World

const MAX_LIVES := 5

@onready var becky: Becky = $Becky
@onready var spawner: Spawner = $Spawner

@onready var music: AudioStreamPlayer = $Music

@onready var main_menu: Control = $CanvasLayer/MainMenu
@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton

@onready var round_label: Label = $CanvasLayer/RoundProgress/Label
@onready var time_progress: ProgressBar = $CanvasLayer/RoundProgress/TimeProgress
@onready var kill_progress: ProgressBar = $CanvasLayer/RoundProgress/KillProgress

@onready var health_bar: ProgressBar = $CanvasLayer/Status/HealthBar

@onready var game_over_panel: Control = $CanvasLayer/GameOverPanel
@onready var game_over_panel_label: Label = $CanvasLayer/GameOverPanel/Container/MarginContainer/Label
@onready var to_menu_button: Button = %ToMenuButton

@onready var losing_indicator: Control = $CanvasLayer/LosingIndicator
@onready var losing_indicator_label: Control = $CanvasLayer/LosingIndicator/Label

@onready var resource1: Label = $CanvasLayer/Resources/Container/Resource1
@onready var resource2: Label = $CanvasLayer/Resources/Container/Resource2

@onready var rounds: Node = $Rounds
@onready var next_round_site: Site = $NextRound
@onready var sites: Array[Site] = [next_round_site, $Upgrades1, $Upgrades2, $Upgrades3]

var current_round := 0
var lives := 5
var between_rounds := false
var restore_health_tween: Tween
var volume_tween: Tween

func _ready():
	becky.process_mode = Node.PROCESS_MODE_DISABLED
	becky.hide()
	
	main_menu.show()
	play_button.pressed.connect(func():
		main_menu.hide()
		spawner.set_round($Rounds/Round1)
		becky.show()
		becky.process_mode = Node.PROCESS_MODE_INHERIT
		music.play()
	)
	
	to_menu_button.pressed.connect(reset)
	game_over_panel.hide()
	
	next_round_site.interacted.connect(func(_alt): start_next_round())
	spawner.round_ended.connect(on_round_ended)
	spawner.enemy_reached_end.connect(on_enemy_reached_end)
	
	for site in sites:
		site.disable()

func _process(_delta: float):
	time_progress.value = spawner.round_current_time / spawner.round_total_time
	kill_progress.value = float(spawner.round_dead_enemies) / spawner.round_total_enemies
	health_bar.value = becky.health / Becky.MAX_HEALTH
	
	if becky.health <= 0.0:
		game_over("You have died :(")
	
	resource1.text = "Placeholder 1: " + str(becky.money[0])
	resource2.text = "Placeholder 2: " + str(becky.money[1])
	
	losing_indicator.visible = lives < MAX_LIVES
	losing_indicator_label.text = str(lives) + "/" + str(MAX_LIVES)

func game_over(text: String):
	game_over_panel_label.text = text
	game_over_panel.show()
	becky.process_mode = Node.PROCESS_MODE_DISABLED
	becky.hide()
	music.stop()

func reset():
	lives = MAX_LIVES
	game_over_panel.hide()
	becky.health = Becky.MAX_HEALTH
	for child in get_children():
		if child is Enemy or child is Projectile:
			child.queue_free()
	spawner.set_round($Rounds/Round1)
	
	becky.reset()
	current_round = 0
	between_rounds = false
	
	main_menu.show()
	
func on_round_ended():
	if game_over_panel.visible: return
	
	for site in sites:
		site.enable()
	
	between_rounds = true
	current_round += 1
	lives = MAX_LIVES
		
	restore_health_tween = create_tween()
	restore_health_tween.tween_property(becky, "health", Becky.MAX_HEALTH, 4.0)
	restore_health_tween.parallel().tween_property(becky, "shield_health", Becky.MAX_SHIELD_HEALTH, 2.0)
	
	if volume_tween != null:
		volume_tween.kill()
	volume_tween = create_tween()
	volume_tween.tween_property(music, "volume_db", -10.0, 2.0)

func start_next_round():
	if !(between_rounds and current_round < rounds.get_child_count()):
		return
		
	restore_health_tween.kill()
	becky.health = Becky.MAX_HEALTH
	spawner.set_round($Rounds.get_child(current_round))
	for site in sites:
		site.disable()
	
	if volume_tween != null:
		volume_tween.kill()
	volume_tween = create_tween()
	volume_tween.tween_property(music, "volume_db", 0.0, 2.0)
func on_enemy_reached_end():
	lives -= 1
	if lives <= 0:
		game_over("They took all the prairie dogs :(")
