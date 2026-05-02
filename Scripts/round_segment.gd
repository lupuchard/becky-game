extends Node
class_name RoundSegment

@export var enemy: PackedScene
@export var amount: int = 1
@export var seconds_between: float
@export var simultaneous: bool = false
@export var paths: Array[Path2D]
@export var boss: bool = false
