extends CharacterBody2D

const W_Type = GameState.DMGTYPE.MD_BLAZE

func _physics_process(delta):
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
#	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func reflect():
	$CollisionShape2D.set_deferred("disabled", true)
	$ReflectSound.play()
	velocity.x = 0
	velocity.y = 0
#	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func kill():
	destroy()
