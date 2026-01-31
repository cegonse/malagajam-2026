extends Camera2D

@export
var left_border: Node2D

@export
var right_border: Node2D

const border_scale = Vector2(10,15)

func _ready() -> void:
	left_border.scale = border_scale
	right_border.scale = border_scale
