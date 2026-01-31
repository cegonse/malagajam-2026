extends Area2D

@export
var spawn_point: Node2D

func _ready() -> void:
	body_entered.connect(on_body_entered)
	spawn_point.get_node("Sprite2D").scale = Vector2.ZERO

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	(body as Player).on_death(spawn_point)
