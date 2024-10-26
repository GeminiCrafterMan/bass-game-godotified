extends CharacterBody2D

const W_Type = 24	# This is CR's Double Fin Shredder!!
var dying : bool
var spins : int
var detectpos

func _ready():
	$SpawnSound.play()
	$AnimatedSprite2D.play("Generate")
	velocity.y = 0
	detectpos = GameState.playerposy
		
		
func _physics_process(_delta):
	move_and_slide()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		queue_free()
	
	if ($AnimatedSprite2D.animation == "Generate") and ($AnimatedSprite2D.get_frame() == 3):
		spins += 1
		velocity.x = velocity.x * 1.5
		if spins > 3:
			if detectpos == GameState.playerposy:
				velocity.x = velocity.x * 74
				$SpawnSound.play()
				$AnimatedSprite2D.play("Copy")
				GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 2
		if spins == 10:
			queue_free()
		
	
	if ($AnimatedSprite2D.animation == "Copy") and ($AnimatedSprite2D.get_frame() == 4):
		velocity.x = velocity.x * 4
		$AnimatedSprite2D.play("Copy-loop")
	
	if dying == true:
		if ($AnimatedSprite2D.get_frame() == 0):
			velocity.x = velocity.x * 0.7
		velocity.x = velocity.x * 0.8
		if ($AnimatedSprite2D.get_frame() == 1):
			GameState.onscreen_sp_bullets = 0
			queue_free()
	
	
	if velocity.x == 0:
		destroy()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets = 0
	queue_free()

func destroy():
	$HitSound.play()
	velocity.y = 0
	$AnimatedSprite2D.play("Copy-hit")
	dying = true
	
	

func kill():
	pass

func reflect():
	pass
