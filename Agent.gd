extends CharacterBody2D

@export var max_speed = 350
@export var steer_force = 0.1
@export var look_ahead = 150
@export var num_rays = 20

var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
#var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO


func _ready() -> void:
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		
		
func _physics_process(delta: float) -> void:
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = chosen_dir.rotated(rotation) * max_speed
	velocity = lerp(velocity, desired_velocity, steer_force)
	## Godot3 rotation = velocity.angle()
	var target_position = position + velocity
	rotation = position.angle_to_point(target_position)
	move_and_collide(velocity * delta)
	
	
func set_interest() -> void:
	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()
		
		
func set_default_interest() -> void:
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)
	
	
func set_danger() -> void:
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var params := PhysicsRayQueryParameters2D.new()
		params.from = position
		params.to = position + ray_directions[i].rotated(rotation) * look_ahead
		params.exclude = [self]
		if space_state.intersect_ray(params):
			danger[i] = 1.0
		else:
			danger[i] = 0.0
			

func choose_direction() -> void:
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		if danger[i] > 0:
			interest[i] = 0.0
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
	
	
	
	
