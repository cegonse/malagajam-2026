extends Area2D

var spawn_point: Node2D

func _ready() -> void:
	spawn_point = get_parent().get_node("Spawn")
	body_entered.connect(on_body_entered)
	spawn_point.get_node("Sprite2D").scale = Vector2.ZERO

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	(body as Player).on_death(spawn_point)
