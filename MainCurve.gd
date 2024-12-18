extends Node2D

var track: Path2D
var path: PathFollow2D

var timer: float = 0.0
var tick: int = 0


func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Players")
	track = find_child("Track")
	path = track.find_child("Path")
	for player in players:
		player.track = track
		player.path = path
	

func _process(delta: float) -> void:
	timer += delta
	if int(timer) > tick: ## Next Tick
		do_tick(delta)


## Process Tick
func do_tick(_delta) -> void:
	tick += 1
	if(tick % 1 == 0):
		pass
