extends StaticBody2D

class_name Spike

func _on_hurt_body_entered(body):
	body.DmgQueue = 80
