extends AnimatedSprite2D

func _process(delta):
	await animation_finished
	queue_free()
