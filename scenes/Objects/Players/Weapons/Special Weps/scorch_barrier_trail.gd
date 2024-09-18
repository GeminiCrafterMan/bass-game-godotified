extends AnimatedSprite2D

var animation_played = false

func _process(_delta):
	if not animation_played:
		if GameState.character_selected == 2:
			play("Copy")
		else:
			play("Bass")
		animation_played = true
	await animation_finished
	queue_free()
