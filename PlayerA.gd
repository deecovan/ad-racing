extends CharacterBody2D


var track: Path2D
var path: PathFollow2D
var mem = {
	tick  = 0,   ## counted
	delta = 0.0  ## average 
}
var extrem_rot = {
	progress = 0.0,
	rotation = 0.0,
	distance = 0.0
}

var speed := 0.0
var gConst: float = 9.81

## Each car must be configured
@export var longitude_acc_limit := 2.0 ## acceleration limit in g. 3g equals 3*9.81=29.43  20px/s*s
@export var longitude_decl_limit := 3.0 ## decceleration/breaking limit in g. 3g equals 3*9.81=29.43  20px/s*s
@export var ang_speed    := 0.25   ## max angular speed in radians/s
@export var look_step    := 0.15   ## look step to look ahead (s)
@export var look_ahead   := 3.0    ## look ahead in seconds
## Tested max speed in last changed logic was 131.32
@export var max_speed    := 100.0  ## Max speed in pixels/second
#@export var start_offset := 0.0   ## Start position offset in pixels

enum {BRAKE, ACCELERATE, COAST}
var state = ACCELERATE

var last_progress_ratio = 1.0 ## 100% on start
var timer: float = 0.0
var tick: int = 0
var leaf: int = 0
var lap_tick: int = 0


func _process(delta: float) -> void:
	timer += delta
	tick += 1
	var _delta = timer / float(tick)
	
	## Save progress
	var current_path_progress = path.progress
	
	if timer * 10 > leaf: ## Do Leaf each 1/10 sec
		do_leaf(delta)
	
	$CyanPoint.hide()
	extrem_rot = find_extrem_rotation(
		current_path_progress, speed, look_ahead, look_step, _delta)
	$CyanPoint.show()
	
	if extrem_rot.rotation > ang_speed:
		# Check brake_distance
		if (extrem_rot.progress - current_path_progress) < extrem_rot.brake_distance:
			speed = slow_down(delta)
			if state != BRAKE:
				state = BRAKE
				print (var_to_str(extrem_rot), " speed: %.2f " % speed, "BRAKE")
				$CyanPoint.play("BRAKE")
	else:
		if state != ACCELERATE:
			state = ACCELERATE
			print ("ACCELERATE")
			$CyanPoint.play("ACCELERATE")
			$AnimatedSprite2D.play("ACCELERATE")
		speed = accelerate(delta)
		
	## Restore progress
	path.progress = current_path_progress
	## Update progress
	path.progress  += speed * delta
	
	# Prints debug info if current rotation reach the limits.
	var print_rotation = abs (
			abs(global_rotation)
			- abs(path.global_rotation))
	if print_rotation > ang_speed:
		print(
			"curr.point: ", int(current_path_progress),
			" speed: %.2f" % speed,
			" rotation: %.2f" % print_rotation,
			" brake point: ", int(extrem_rot.progress),
			" distance: ", int(extrem_rot.brake_distance),
			)
	
	if path.progress_ratio < last_progress_ratio:
		print ("===============================================================",
		" Lap: ", lap_tick, " time: %.2f" % timer)
		lap_tick += 1
		
	# Detect side of rotation and play animation under braking
	if state == BRAKE :
		if abs(global_rotation)-abs(path.global_rotation) > 0:
			$AnimatedSprite2D.flip_v = true
		else:
			$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.play("TURN")
	
	## Move player
	global_rotation = path.global_rotation
	global_position = path.global_position
	last_progress_ratio = path.progress_ratio

## Process Leaf
func do_leaf(_delta: float) -> void:
	leaf += 1


func find_extrem_rotation(cur_path_progress, cur_speed, ahead, step, delta):
	var remember_path_progress = path.progress
	path.progress = cur_path_progress
	var ret = {
		progress = cur_path_progress,
		rotation = 0.0,
		brake_distance = 0.0
	}
	var check_rotation_from = path.global_rotation
	var last_rotation := 0.0
	for i in range(int(ahead/step), 0, -1):
		var check_position = i * step * cur_speed
		path.progress = cur_path_progress + check_position
		var check_rotation = path.global_rotation
		var cur_rotaton = abs (abs(check_rotation) - abs(check_rotation_from))
		#$CyanPoint.hide()
		if cur_rotaton > last_rotation:
			var brake_distance = (
				(cur_rotaton / ang_speed)
				* cur_speed * cur_speed * delta
				) / longitude_decl_limit
			ret = {
				progress = path.progress,
				rotation = cur_rotaton,
				brake_distance = brake_distance
			}
			$CyanPoint.global_position = path.global_position
			$CyanPoint.global_rotation = path.global_rotation
			
			
		last_rotation = cur_rotaton
		check_rotation_from = check_rotation
		
	path.progress = remember_path_progress
	return ret
	

func slow_down(delta: float) -> float:
	return clamp(speed - longitude_acc_limit * gConst * delta, 0, max_speed)
	
	
func accelerate(delta: float) -> float:
	return clamp(speed + longitude_acc_limit * gConst * delta, 0, max_speed)
	
	
#func change_state(new_state):
	#state = new_state
	#match state:
	
	
