extends AnimatedSprite2D

func _process(delta):
	if GameState.character_selected == 0:
		play("Bass")
	else:
		play("Copy")
