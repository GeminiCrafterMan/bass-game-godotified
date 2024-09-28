extends AnimatedSprite2D

var animation_played = false

func _process(_delta):
	await animation_finished
	queue_free()
