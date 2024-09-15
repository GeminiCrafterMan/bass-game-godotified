extends CharacterBody2D

const W_Type = 7	# This is Fin Shredder.

func _ready():
	$SpawnSound.play()
	if !GameState.character_selected == 0:
		$AnimatedSprite2D.play("Copy")
	else:
		$AnimatedSprite2D.play("Bass")
		
		
func _physics_process(delta):
	if ($AnimatedSprite2D.animation == "Bass") and ($AnimatedSprite2D.get_frame() == 3):
		velocity.x = velocity.x * 4
		$AnimatedSprite2D.play("Bass-loop")
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$HitSound.play()
	$CollisionShape2D.set_disabled(true)
	velocity.x = velocity.x * 0.5
	velocity.y = 0
	if !GameState.character_selected == 0:
		$AnimatedSprite2D.play("Copy-hit")
	else:
		$AnimatedSprite2D.play("Bass-hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
	

func kill():
	pass

func reflect():
	pass	# not reflectable
