extends Area2D

@export
var wall: Node2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	if (body as Player).feathers >= 5:
		wall.position = Vector2(6000 , 6000)
