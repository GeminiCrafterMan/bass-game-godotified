extends CharacterBody2D

const W_Type = 3	# This is Copy Robot's large charge shot.

func _ready():
	$SpawnSound.play()

func _physics_process(delta):
	if move_and_slide() == true:
		$AnimatedSprite2D.play("hit")
		$HitSound.play()
		velocity.x = 0
		velocity.y = 0
		$CollisionShape2D.set_disabled(true)
		await $AnimatedSprite2D.animation_finished
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

