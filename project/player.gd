extends CharacterBody2D
class_name Player

const horizontal_speed = 100.0
const jump_speed = 300.0
const max_vertical_velocity = 500.0
var animator: AnimatedSprite2D
var can_rotate = false
var left_foot_sensor: Area2D = null
var right_foot_sensor: Area2D = null
var coyote_timer = 0.0
var has_mask = false
var feathers = 0
var alive = true
var credits = false

func on_credits() -> void:
	credits = true
	rotation = 0
	position = Vector2(-657,-1466)

func _ready() -> void:
	left_foot_sensor = get_node("LeftFootSensor")
	right_foot_sensor = get_node("RightFootSensor")
	animator = get_node("Sprite2D")
	animator.animation_finished.connect(on_animation_finised)

func _process(delta: float) -> void:
	update_animations()

func on_collected_mask() -> void:
	has_mask = true

func on_feather_collected() -> void:
	feathers = feathers + 1

func update_animations() -> void:
	var prev = animator.animation
	var rot = int(rotation_degrees)
	var mask_suffix = "_owl" if has_mask else ""
	
	if not alive:
		return
	
	if prev == "idle" + mask_suffix or prev == "walk" + mask_suffix:
		if up_direction == Vector2.UP or up_direction == Vector2.DOWN:
			if abs(velocity.x) > 0:
				var flip = false if velocity.x > 0 else true
				flip = not flip if up_direction == Vector2.DOWN else flip
				animator.flip_h = flip
				animator.play("walk" + mask_suffix)
		else:
			if abs(velocity.y) > 0:
				var flip = false if velocity.y > 0 else true
				animator.flip_h = flip
				animator.play("walk" + mask_suffix)
	
	if prev == "jump" + mask_suffix or prev == "fall" + mask_suffix:
		if is_on_floor():
			animator.play("idle" + mask_suffix)
	
	if prev == "walk":
		if velocity.length() < 0.1:
			animator.play("idle" + mask_suffix)
	
	if prev != "jump" + mask_suffix:
		if up_direction == Vector2.UP and velocity.y > 0 or up_direction == Vector2.DOWN and velocity.y < 0 or up_direction == Vector2.LEFT and velocity.x > 0 or up_direction == Vector2.RIGHT and velocity.x < 0:
			animator.play("fall" + mask_suffix)

var last_spawn: Node2D

func on_animation_finised() -> void:
	var mask_suffix = "_owl" if has_mask else ""
	
	if animator.animation == "death":
		animator.play("revive")
		velocity = Vector2.ZERO
		position = last_spawn.global_position
		rotation = last_spawn.rotation
		up_direction = Vector2.UP.rotated(rotation)

	if animator.animation == "revive" and animator.frame == 4:
		alive = true
		animator.play("idle" + mask_suffix)

func on_death(spawn: Node2D) -> void:
	animator.play("death")
	alive = false
	last_spawn = spawn
	velocity = Vector2.ZERO

func is_on_coyote_time(delta: float, on_floor: bool) -> bool:
	var left = left_foot_sensor.has_overlapping_bodies()
	var right = right_foot_sensor.has_overlapping_bodies()

	coyote_timer = coyote_timer + delta
	
	if on_floor:
		coyote_timer = 0
	
	if left and not right:
		return coyote_timer <= 0.3
	elif not left and right:
		return coyote_timer <=  0.3
	
	return false

func handle_vertical_movement(delta: float) -> void:
	if not alive:
		return
	
	var gravity_magnitude = (get_gravity() * delta).y
	var gravity = up_direction.rotated(PI) * gravity_magnitude
	var jump_velocity = up_direction * jump_speed
	var on_floor = is_on_floor()
	
	if not on_floor:
		if velocity.length() < max_vertical_velocity:
			velocity += gravity
	else:
		can_rotate = true;
		
	var on_coyote_time = is_on_coyote_time(delta, on_floor)
	var can_jump = on_floor or on_coyote_time
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity = jump_velocity
		var mask_suffix = "_owl" if has_mask else ""
		animator.play("jump" + mask_suffix)

func close_to(v1: Vector2, v2: Vector2) -> bool:
	return v1.distance_to(v2) < 0.1

func handle_horizontal_movement(delta: float) -> void:
	if not alive:
		return
	
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
	if not has_mask:
		return
	
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

func _physics_process(delta: float) -> void:
	if credits:
		return
	#handle_rotation_discrete()
	handle_rotation_direct()
	handle_vertical_movement(delta)
	handle_horizontal_movement(delta)
	move_and_slide()
