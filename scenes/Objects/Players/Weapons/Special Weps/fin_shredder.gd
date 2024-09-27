extends CharacterBody2D

const W_Type = 7	# This is Fin Shredder.
var dying : bool

func _ready():
	$SpawnSound.play()
	if !GameState.character_selected == 0:
		$AnimatedSprite2D.play("Copy")
	else:
		$AnimatedSprite2D.play("Bass")
	velocity.y = 2
		
		
func _physics_process(_delta):
	move_and_slide()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != 4:
		queue_free()
	
	if ($AnimatedSprite2D.animation == "Bass") and ($AnimatedSprite2D.get_frame() == 3) and (is_on_floor()):
		velocity.x = velocity.x * 4
		$AnimatedSprite2D.play("Bass-loop")
	
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
	if !GameState.character_selected == 0:
		$AnimatedSprite2D.play("Copy-hit")
	else:
		$AnimatedSprite2D.play("Bass-hit")
	dying = true
	
	

func kill():
	pass

func reflect():
	pass	# not reflectable
