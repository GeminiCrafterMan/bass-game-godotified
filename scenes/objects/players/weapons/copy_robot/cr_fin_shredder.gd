extends CharacterBody2D

const W_Type = 23	# This is CR's Fin Shredder.
var dying : bool

func _ready():
	$SpawnSound.play()
	$AnimatedSprite2D.play("Copy")
	velocity.y = 2
		
		
func _physics_process(_delta):
	move_and_slide()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		queue_free()
	
	if ($AnimatedSprite2D.animation == "Copy") and ($AnimatedSprite2D.get_frame() == 3) and (is_on_floor()):
		velocity.x = velocity.x * 4
		$AnimatedSprite2D.play("Copy-loop")
	
	if dying == true:
		if ($AnimatedSprite2D.get_frame() == 0):
			velocity.x = velocity.x * 0.7
		velocity.x = velocity.x * 0.8
		if ($AnimatedSprite2D.get_frame() == 3):
			queue_free()
	
	
	if !is_on_floor() or velocity.x == 0:
		destroy()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$HitSound.play()
	velocity.y = 0
	$AnimatedSprite2D.play("Copy-hit")
	dying = true
	
	

func kill():
	pass

func reflect():
	destroy()
