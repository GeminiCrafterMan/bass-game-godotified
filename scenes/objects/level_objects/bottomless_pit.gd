extends Area2D

class_name BottomlessPit # This doesn't work. Why? Why can't we have simple Area2D spikes and bottomless pits that we can define the shape of in the stage?

func _on_body_exited(body: Node2D) -> void:
	body.DmgQueue = 80
