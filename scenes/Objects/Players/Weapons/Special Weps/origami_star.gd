extends CharacterBody2D

const W_Type = 8	# This is Origami Star.
var broken

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
func _physics_process(delta):
	if broken == true:
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		velocity.y = velocity.y + 12
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
	$CollisionShape2D.set_deferred("disabled", true)
	$ReflectSound.play()
	$AnimatedSprite2D.set_frame_and_progress(0, 0)
	if velocity.x < 0:
		velocity.x = 20
	if velocity.x > 0:
		velocity.x = -20
	velocity.y = -90
	broken = true
	
