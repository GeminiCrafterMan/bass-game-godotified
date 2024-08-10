extends CharacterBody2D

var projectile
var buster_timer : int

var aim : int
	
var projectile_scenes = [preload("res://scenes/Objects/Players/Weapons/Bass/buster.tscn")]
	
func _ready():
	$SpawnSound.play()

func _process(delta):
	buster_timer = buster_timer + 1
	
	if (Input.is_action_just_pressed("buster" ) && Input.is_action_pressed("input_down")):
		$AnimatedSprite2D.play("Down")
		aim = -1
		

	if (Input.is_action_just_pressed("buster" ) && Input.is_action_pressed("input_up")):
		aim = 1
		$AnimatedSprite2D.play("Diag")
		

	if (Input.is_action_just_pressed("buster" ) && Input.is_action_pressed("input_up") && !Input.is_action_pressed("input_left") && !Input.is_action_pressed("input_right")):
		aim = 2
		$AnimatedSprite2D.play("Up")
		

	if (Input.is_action_just_pressed("buster") && !Input.is_action_pressed("input_down") && !Input.is_action_pressed("input_up")):
		aim = 0
		$AnimatedSprite2D.play("Forward")
		

	if (Input.is_action_just_pressed("buster") && Input.is_action_pressed("input_left")):
		scale.x = -1
		
	if (Input.is_action_just_pressed("buster") && Input.is_action_pressed("input_right")):
		scale.x = 1
		


	if buster_timer > 17:
		projectile = projectile_scenes[0].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		if aim == -1:
			if scale.x == -1:
				projectile.velocity.x = -120
			else:
				projectile.velocity.x = 120
			projectile.velocity.y = 120
		
		if aim == 0:
			if scale.x == -1:
				projectile.velocity.x = -240
			else:
				projectile.velocity.x = 240
			projectile.velocity.y = 0
		
		if aim == 1:
			if scale.x == -1:
				projectile.velocity.x = -120
			else:
				projectile.velocity.x = 120
			projectile.velocity.y = -120
		
		if aim == 2:
			projectile.velocity.x = 0
			projectile.velocity.y = -240
		
		buster_timer = 0
	return
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

