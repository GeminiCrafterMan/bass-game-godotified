extends CharacterBody2D

const W_Type = 8	# This is Origami Star.
var broken

func _ready():
	$SpawnSound.play()
		
func _physics_process(_delta):
	if GameState.current_weapon != GameState.WEAPONS.ORIGAMI:
		GameState.onscreen_sp_bullets -= 1
		queue_free()	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if broken == true:
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		velocity.y = velocity.y + 12
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	GameState.onscreen_sp_bullets -= 1
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func kill():
	pass

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
	
