extends Area2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	(body as Player).on_feather_collected()
	position = Vector2(6000, 6000)
