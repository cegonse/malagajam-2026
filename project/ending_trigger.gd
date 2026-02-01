extends Area2D

@export
var camera: CoolCamera

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	
	camera.on_ending()
