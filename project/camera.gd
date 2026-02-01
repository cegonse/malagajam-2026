extends Camera2D
class_name CoolCamera

@export
var left_border: Node2D

@export
var right_border: Node2D

@export
var player: Node2D

const border_scale = Vector2(10,15)
var is_ending = false

func on_ending() -> void:
	is_ending = true

func _process(delta: float) -> void:
	if not is_ending:
		return
	
	position = position.move_toward(player.position, delta * 600)

func _ready() -> void:
	left_border.scale = border_scale
	right_border.scale = border_scale
