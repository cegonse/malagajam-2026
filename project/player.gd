extends CharacterBody2D
class_name Player

const horizontal_speed = 100.0
const jump_speed = 300.0
const max_vertical_velocity = 500.0
var can_rotate = false
var left_foot_sensor: Area2D = null
var right_foot_sensor: Area2D = null
var left_foot_collider: CollisionShape2D = null
var right_foot_collider: CollisionShape2D = null

func _ready() -> void:
	left_foot_sensor = get_node("LeftFootSensor")
	right_foot_sensor = get_node("RightFootSensor")
	left_foot_collider = get_node("LeftFootCollider")
	right_foot_collider = get_node("RightFootCollider")

func on_death(spawn: Node2D) -> void:
	velocity = Vector2.ZERO
	position = spawn.global_position
	rotation = spawn.rotation
	up_direction = Vector2.UP.rotated(rotation)

func handle_vertical_movement(delta: float) -> void:
	var gravity_magnitude = (get_gravity() * delta).y
	var gravity = up_direction.rotated(PI) * gravity_magnitude
	var jump_velocity = up_direction * jump_speed
	
	if not is_on_floor():
		if velocity.length() < max_vertical_velocity:
			velocity += gravity
	else:
		can_rotate = true;

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

func handle_rotation_discrete() -> void:
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
	
	if can_rotate:
		can_rotate = false
		rotate(rotation)
		up_direction = up_direction.rotated(-rotation)

func handle_rotation_direct() -> void:
	var x_axis = Input.get_axis("rotate_left", "rotate_right")
	var y_axis = Input.get_axis("rotate_down", "rotate_up")
	var axis = Vector2(-int(x_axis), int(y_axis))
	var prev_up_rotation = up_direction
	
	var target_angle = int(rad_to_deg(abs(axis.angle_to(up_direction))))
	if target_angle == -180 and is_on_floor():
		return
	
	if can_rotate and axis != Vector2.ZERO:
		can_rotate = false
		up_direction = axis
		
		if close_to(up_direction, Vector2.UP):
			rotation = 0
		elif close_to(up_direction, Vector2.DOWN):
			rotation = -PI
		elif close_to(up_direction, Vector2.RIGHT):
			rotation = PI*0.5
		elif close_to(up_direction, Vector2.LEFT):
			rotation = -PI*0.5

func handle_coyote_time() -> void:
	left_foot_collider.disabled = true
	right_foot_collider.disabled = true

	if not is_on_floor():
		return
	
	var left = left_foot_sensor.has_overlapping_bodies()
	var right = right_foot_sensor.has_overlapping_bodies()
	
	if left and not right:
		left_foot_collider.disabled = true
		right_foot_collider.disabled = false
	elif not left and right:
		left_foot_collider.disabled = false
		right_foot_collider.disabled = true

func _physics_process(delta: float) -> void:
	#handle_rotation_discrete()
	handle_coyote_time()
	handle_rotation_direct()
	handle_vertical_movement(delta)
	handle_horizontal_movement(delta)
	move_and_slide()
