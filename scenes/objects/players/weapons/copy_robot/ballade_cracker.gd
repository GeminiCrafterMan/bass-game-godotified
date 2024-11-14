extends CharacterBody2D

const W_Type = 17	# This is Ballade Cracker.

func _ready():
	$SpawnSound.play()

func _physics_process(_delta):
	if move_and_slide() == true:
		destroy()
		
	if GameState.current_weapon != GameState.WEAPONS.BALLADE:
		GameState.onscreen_sp_bullets = 0
		queue_free()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets = 0
	queue_free()

func destroy():
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$CollisionShape2D.set_deferred("disabled", true)
	#$Blast.set_deferred("disabled", false)
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	GameState.onscreen_sp_bullets = 0
	queue_free()
	
func kill():
	destroy()

func reflect():
	destroy()
	
