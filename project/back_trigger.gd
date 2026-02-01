extends Area2D

@export
var wall: Node2D
var original_position: Vector2

func _ready() -> void:
	original_position = wall.position
	wall.position = Vector2(6000,6000)
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	wall.position = original_position
