extends Node

@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@export var debug: bool = true
var line: Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if debug:
		line = Line2D.new()   
		line.default_color = Color(0.5,0.5,1,0.5)  
		line.width = 1  
		for point in path.curve.get_baked_points():  
			line.add_point(point + path.position)
		get_parent().add_child.call_deferred(line)
		

func get_path_direction(pos: Vector2) -> Vector2:
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset
	return path_follow.transform.x
	
	
