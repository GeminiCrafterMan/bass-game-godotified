extends CharacterBody2D

const W_Type = 1	# This is Copy Robot's basic buster shot.

func _ready():
	$SpawnSound.play()

func _physics_process(_delta):
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_bullets -= 1
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	GameState.onscreen_bullets -= 1
	queue_free()

func kill():
	destroy()

func reflect():
	$ReflectSound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	velocity.x = -velocity.x
	velocity.y = -180
