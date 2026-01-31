extends CharacterBody2D

const horizontal_speed = 100.0
const jump_speed = 300.0

func handle_vertical_movement(delta: float) -> void:
	var gravity_magnitude = (get_gravity() * delta).y
	var gravity = up_direction.rotated(PI) * gravity_magnitude
	var jump_velocity = up_direction * jump_speed
	
	if not is_on_floor():
		velocity += gravity

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity = jump_velocity

func close_to(v1: Vector2, v2: Vector2) -> bool:
	return v1.distance_to(v2) < 0.1

func handle_horizontal_movement(delta: float) -> void:
	var x_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_down", "move_up")
	
	var should_move_horizontally = close_to(up_direction, Vector2.UP) or close_to(up_direction, Vector2.DOWN)
	var should_move_vertically = close_to(up_direction, Vector2.LEFT) or close_to(up_direction, Vector2.RIGHT)
	
	if should_move_horizontally:
		velocity.x = x_axis * horizontal_speed
	elif should_move_vertically:
		velocity.y = -y_axis * horizontal_speed

func handle_rotation() -> void:
	var rotation = 0
	var rotate_left = Input.is_action_just_pressed("rotate_left")
	var rotate_right = Input.is_action_just_pressed("rotate_right")
	var rotation_axis = -int(rotate_left) + int(rotate_right)
	
	if close_to(up_direction, Vector2.UP):
		rotation = PI*0.5 * rotation_axis
	elif close_to(up_direction, Vector2.DOWN):
		rotation = PI*0.5 * -rotation_axis
	elif close_to(up_direction, Vector2.RIGHT):
		rotation = PI*0.5 * rotation_axis
	elif close_to(up_direction, Vector2.LEFT):
		rotation = PI*0.5 * rotation_axis
	
	if rotation != 0:
		rotate(rotation)
		up_direction = up_direction.rotated(-rotation)

func _physics_process(delta: float) -> void:
	handle_rotation()
	handle_vertical_movement(delta)
	handle_horizontal_movement(delta)
	move_and_slide()
