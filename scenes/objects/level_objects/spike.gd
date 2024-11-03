extends StaticBody2D

class_name Spike
@export var damage : int

func _on_hurt_body_entered(body):
	body.DmgQueue = damage
