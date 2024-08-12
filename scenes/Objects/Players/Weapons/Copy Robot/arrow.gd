
extends CharacterBody2D

var timer : int
var flashtimer : int

func _process (delta):
	
	if move_and_slide() == true && $AnimatedSprite2D.animation == "move":
		$AnimatedSprite2D.play("stick")
		timer = 0
		velocity.x = 0
		
	timer = (timer + 1)
	if $AnimatedSprite2D.animation != "stick":
		if timer == 100:
			$AnimatedSprite2D.animation = "move"
			if velocity.x < 0:
				velocity.x = -50
			else:
				velocity.x = 50
		if timer > 100 && velocity.x > -300 && velocity.x < 300:
				velocity.x = velocity.x * 1.03
	
	if timer > 300 && $AnimatedSprite2D.animation == "stick":
		flashtimer = (flashtimer + 1)
		if $AnimatedSprite2D.animation != "explode":
			if flashtimer == 3:
				$AnimatedSprite2D.hide()
			if flashtimer == 6:
				$AnimatedSprite2D.show()
				flashtimer = 0
		else:
			$AnimatedSprite2D.show()
	if timer == 400 && $AnimatedSprite2D.animation == "stick":
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()
