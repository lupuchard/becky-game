extends Node2D
class_name Spawner

var round_segments: Array[RoundSegment]
var next_segment: int = 0

var current_segments: Array[RoundSegment]
var current_segment_spawned: Array[int]
var current_segment_times: Array[float]

func _ready():
	pass

func set_round(new_round: Node):
	round_segments.clear()
	current_segments.clear()
	current_segment_times.clear()
	
	for child in new_round.get_children():
		if child is RoundSegment:
			round_segments.push_back(child)
	
	if round_segments.size() > 0:
		current_segments.push_back(round_segments[0])
		current_segment_spawned.push_back(0)
		current_segment_times.push_back(0)
		next_segment = 1

func _process(delta: float):
	if round_segments.size() == 0:
		return
	
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
	next_segment = 1
	
	if current_segments.back().simultaneous:
		push_next_segment()

func spawn_from(segment: RoundSegment):
	if segment.enemy == null: return
	var new_enemy: Enemy = segment.enemy.instantiate()
	new_enemy.possible_paths = segment.paths
	get_parent().add_child(new_enemy)

func end_round():
	round_segments.clear()
