extends Node2D
class_name Spawner

signal round_ended
signal enemy_reached_end

var current_round: Round
var round_segments: Array[RoundSegment]
var next_segment: int = 0

var current_segments: Array[RoundSegment]
var current_segment_spawned: Array[int]
var current_segment_times: Array[float]

var round_total_enemies: int = 0
var round_dead_enemies: int = 0
var round_total_time: float = 0.0
var round_current_time: float = 0.0

func _ready():
	pass

func set_round(new_round: Round):
	current_round = new_round
	round_segments.clear()
	current_segments.clear()
	current_segment_spawned.clear()
	current_segment_times.clear()
	next_segment = 0
	
	round_total_enemies = 0
	round_dead_enemies = 0
	var times: Array[float] = [0.0]
	var prev_simultaneous = false
	for child in new_round.get_children():
		if child is RoundSegment:
			round_segments.push_back(child)
			round_total_enemies += child.amount
			if prev_simultaneous:
				times.push_back(child.seconds_between * child.amount)
			else:
				times[times.size() - 1] += child.seconds_between * child.amount
			prev_simultaneous = child.simultaneous
	round_total_time = times.max()
	round_current_time = 0.0
	
	push_next_segment()

func _process(delta: float):
	if round_segments.size() == 0:
		return
	
	round_current_time += delta
	
	for i in range(current_segments.size() - 1, -1, -1):
		if current_segment_spawned[i] >= current_segments[i].amount:
			current_segments.remove_at(i)
			current_segment_spawned.remove_at(i)
			current_segment_times.remove_at(i)
	
	if current_segments.size() == 0:
		end_round()
		return
	
	for i in range(0, current_segments.size()):
		var segment = current_segments[i]
		current_segment_times[i] += delta
		if current_segment_times[i] > (current_segment_spawned[i] + 1) * segment.seconds_between:
			spawn_from(segment)
			current_segment_spawned[i] += 1
	
	if current_segment_spawned.back() >= current_segments.back().amount and !current_segments.back().simultaneous:
		push_next_segment()
	

func push_next_segment():
	if next_segment >= round_segments.size():
		return
		
	current_segments.push_back(round_segments[next_segment])
	current_segment_spawned.push_back(0)
	current_segment_times.push_back(0)
	next_segment += 1
	
	if current_segments.back().simultaneous:
		push_next_segment()

func spawn_from(segment: RoundSegment):
	if segment.enemy == null: return
	var new_enemy: Enemy = segment.enemy.instantiate()
	new_enemy.possible_paths = segment.paths
	new_enemy.health *= current_round.health_scaling
	new_enemy.damage *= current_round.damage_scaling
	get_parent().add_child(new_enemy)
	new_enemy.died.connect(enemy_died)
	new_enemy.reached_end.connect(func():
		enemy_died()
		enemy_reached_end.emit()
	)

func enemy_died():
	round_dead_enemies += 1
	if round_dead_enemies >= round_total_enemies:
		round_ended.emit()

func end_round():
	round_segments.clear()
	current_round = null
