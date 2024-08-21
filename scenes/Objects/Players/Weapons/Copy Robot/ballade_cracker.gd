extends CharacterBody2D

const W_Type = 17	# This is Ballade Cracker.

func _ready():
	$SpawnSound.play()

func _physics_process(delta):
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$CollisionShape2D.set_deferred("disabled", true)
	#$Blast.set_deferred("disabled", false)
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func reflect():
	destroy()
	
