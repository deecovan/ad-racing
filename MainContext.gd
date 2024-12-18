extends Node2D

@onready var agents = get_tree().get_nodes_in_group("Agents")
@onready var path = $Path


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for agent in agents:
		agent.set_owner(self)
		

func get_path_direction(pos: Vector2) -> Vector2:
	return path.get_path_direction(pos)
