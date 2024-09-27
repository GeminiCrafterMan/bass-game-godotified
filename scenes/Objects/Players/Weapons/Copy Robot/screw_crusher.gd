extends CharacterBody2D

const W_Type = 16	# This is Screw Crusher.
var gravity = 1400

func _ready():
	$SpawnSound.play()
	


func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()
	
	if GameState.current_weapon != 14:
		destroy()
		
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
	

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
	
func kill():
	pass

func reflect():
	$ReflectSound.play()
	velocity.x = -velocity.x
	velocity.y = -50
