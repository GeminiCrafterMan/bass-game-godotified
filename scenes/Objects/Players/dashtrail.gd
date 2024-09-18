extends AnimatedSprite2D

func _process(_delta):
	await animation_finished
	queue_free()
