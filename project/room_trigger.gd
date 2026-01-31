extends Area2D

@export
var target_room: Node2D

@export
var camera: Camera2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func already_on_room() -> bool:
	print("(dist)" , "-" , abs(camera.position.distance_to(target_room.position)))
	return abs(camera.position.distance_to(target_room.position)) < 0.1

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	print("(cam)" , camera.position , " - ", "(pos)", target_room.position)
		
	if already_on_room():
		return
	
	camera.position = target_room.position
