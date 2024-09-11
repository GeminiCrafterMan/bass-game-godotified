extends CharacterBody2D

const W_Type = 7	# This is Fin Shredder.

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
func _physics_process(delta):
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	pass
	
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass-hit")
	else:
		$AnimatedSprite2D.play("Copy-hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func kill():
	pass

func reflect():
	pass	# not reflectable
