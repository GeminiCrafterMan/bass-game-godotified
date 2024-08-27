extends AnimatedSprite2D

var animation_played = false

func _process(delta):
	if not animation_played:
		#if GameState.character_selected == 0:
		#	play("Bass")
		#else:
		#	play("Copy")
		animation_played = true
	await animation_finished
	queue_free()
