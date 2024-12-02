extends StaticBody2D

class_name wind
@export var push : int

func _on_box_body_entered(body):
	if body.is_in_group("player"):
		body.wind_push = push * 0.01


func _on_box_body_exited(body):
	if body.is_in_group("player"):
		body.wind_push = 0
