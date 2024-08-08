
extends StaticBody2D

var timer : int
var flashtimer : int

func _process (delta):
	timer = (timer + 1)
	if timer > 300:
		flashtimer = (flashtimer + 1)
		if flashtimer == 3:
			$AnimatedSprite2D.hide()
		if flashtimer == 6:
			$AnimatedSprite2D.show()
			flashtimer = 0
	if timer == 400:
		queue_free()
