extends CharacterBody2D

const W_Type = 16	# This is Screw Crusher.
var gravity = 1400

func _ready():
	$SpawnSound.play()

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	gravity = 0
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
