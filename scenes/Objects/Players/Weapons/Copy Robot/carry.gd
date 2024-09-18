
extends StaticBody2D

var timer : int
var flashtimer : int

func _process(_delta):
	if GameState.current_weapon != 11 && $AnimatedSprite2D.animation != "explode":
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()
		
	timer = (timer + 1)
	if timer > 300:
		flashtimer = (flashtimer + 1)
		if $AnimatedSprite2D.animation != "explode":
			if flashtimer == 3:
				$AnimatedSprite2D.hide()
			if flashtimer == 6:
				$AnimatedSprite2D.show()
				flashtimer = 0
		else:
			$AnimatedSprite2D.show()
	if timer == 400:
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()
