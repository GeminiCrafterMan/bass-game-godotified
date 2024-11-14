extends CharacterBody2D

var W_Type = 7	# This is Fin Shredder.
var dying : bool

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 2:
		$AnimatedSprite2D.play("Copy")
		W_Type = 23 #CR's damage values
		$BassHitbox.queue_free()
	else:
		$AnimatedSprite2D.play("Bass")
		$CopyHitbox.queue_free()
	velocity.y = 2
		
		
func _physics_process(_delta):
	move_and_slide()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		queue_free()
	
	if (($AnimatedSprite2D.animation == "Bass") or ($AnimatedSprite2D.animation == "Copy")) and ($AnimatedSprite2D.get_frame() == 3) and (is_on_floor()):
		if !GameState.character_selected == 2:
			velocity.x = velocity.x * 4
			$AnimatedSprite2D.play("Bass-loop")
		else:
			velocity.x = velocity.x * 300
			$AnimatedSprite2D.play("Copy-loop")
	
	if dying == true:
		if ($AnimatedSprite2D.get_frame() == 0):
			velocity.x = velocity.x * 0.7
		velocity.x = velocity.x * 0.8
		if ($AnimatedSprite2D.get_frame() == 3):
			GameState.onscreen_sp_bullets -= 1
			queue_free()
	
	
	if !is_on_floor() or velocity.x == 0:
		destroy()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()

func destroy():
	$HitSound.play()
	velocity.y = 0
	if GameState.character_selected == 2:
		$AnimatedSprite2D.play("Copy-hit")
	else:
		$AnimatedSprite2D.play("Bass-hit")
	dying = true
	
	

func kill():
	$HitSound.play()

func reflect():
	pass
