extends CharacterBody2D

const horizontal_speed = 10.0
const jump_speed = 300.0

func _process(delta: float) -> void:
	var rotation = 0
	
	if Input.is_action_just_pressed("rotate_right"):
		rotation = PI*0.5
	elif Input.is_action_just_pressed("rotate_left"):
		rotation = -PI*0.5
	
	if rotation != 0:
		rotate(rotation)
		up_direction = up_direction.rotated(-rotation)

func _physics_process(delta: float) -> void:
	var gravity = (get_gravity() * delta).y
	var gravity_vec = up_direction.rotated(PI) * gravity
	var jump_vec = up_direction * jump_speed
	
	if not is_on_floor():
		velocity += gravity_vec

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity = jump_vec

	var horizontal_target = 0
	if Input.is_action_pressed("move_left"):
		horizontal_target = -1
	elif Input.is_action_pressed("move_right"):
		horizontal_target = 1

	move_and_slide()
