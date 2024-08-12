extends CharacterBody2D

const W_Type = 15	# This is Screw Crusher.

func _ready():
	$SpawnSound.play()
		
func _physics_process(delta):
	velocity.y = velocity.y + 20
	if move_and_slide() == true:
		$AnimatedSprite2D.play("hit")
		$HitSound.play()
		velocity.x = 0
		velocity.y = 0
		$CollisionShape2D.set_disabled(true)
		await $AnimatedSprite2D.animation_finished
		queue_free()


