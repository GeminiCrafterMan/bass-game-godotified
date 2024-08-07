extends CharacterBody2D

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
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

