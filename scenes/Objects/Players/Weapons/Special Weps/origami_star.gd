extends CharacterBody2D

const W_Type = 8	# This is Origami Star.

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
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
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func reflect():
	$ReflectSound.play()
	velocity.x = -velocity.x
	velocity.y = -velocity.y
