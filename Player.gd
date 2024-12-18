extends CharacterBody2D


var track: Path2D
var path: PathFollow2D
var mem = {
	tick  = 0,   ## counted
	delta = 0.0  ## average 
}

var speed := 0.0
var is_ready = false

## Each car must be configured
@export var ang_speed    := 0.25  ## max angular speed in radians
@export var look_ahead   := 0.25  ## look ahead in seconds
@export var max_speed    := 200.0 ## Max speed in pixels/second
@export var start_offset := 0.0   ## Start position offset in pixels


func _process(delta: float) -> void:
	## @TODO deploy many players with separate path.progress
	if not is_ready and path != null:
		path.progress += start_offset
		is_ready = true
		
	mem.tick += 1
	mem.delta += delta
	var _delta = mem.delta / float(mem.tick)

	## Save progress
	var current_path_progress = path.progress
	
	## Look ahead
	## First: Where will we be in look_ahead seconds
	## Assign values
	path.progress += speed * _delta * 60 * look_ahead
	## Second: What rotation will it be
	# Angular speed is defined as rate of change of angle (in radians). 
	# A simple method to calculate angular speed/velocity is 
	# to divide the velocity of the car( in m/s) by the radius (in m) 
	# of the curved path. 72km/h is 20m/s. Hence angular velocity 
	# will be v/R= 20/80 =0.25 rad/s.
	## Let it be ang_speed (0.5 rads) * look_ahead (0.5 s) == 0.25 rad / s
	var k = ang_speed * look_ahead
	var abs_future_rotation = (
		abs (abs(global_rotation) - abs(path.global_rotation))
		* (speed / max_speed))
	## Check rotation * delta speed
	if abs_future_rotation > k:
		## Break to desired rotation speed
		speed = lerp(speed, speed / (abs_future_rotation / k), 
			_delta / look_ahead)
		#print(speed, ": ", rad_to_deg(abs_future_rotation))
	else:
		## Push to max_speed
		speed = lerp(speed, max_speed, _delta)
		#print(speed)

	## Restore progress
	path.progress = current_path_progress

	## Move player
	path.progress  += speed * delta
	global_rotation = path.global_rotation
	global_position = path.global_position
