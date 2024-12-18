extends Path2D

var path: Path2D
var line: Line2D


func _ready() -> void:
	line = Line2D.new()   
	line.default_color = Color(1,1,1,1)  
	line.width = 20  
	line.antialiased = true
	for point in curve.get_baked_points():  
		line.add_point(point + position)
	get_parent().add_child.call_deferred(line)
