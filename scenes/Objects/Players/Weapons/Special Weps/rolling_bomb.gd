extends CharacterBody2D

const W_Type = 10	#ROOOOOLLING BOMB

enum DIRECTION {
	NONE, 
	LEFT, 
	RIGHT, 
	UP, 
	DOWN
	}


var CurrentDir = DIRECTION.NONE

func _ready():
	$SpawnSound.play()

func _physics_process(_delta):
	pass
	#if CurrentDir == DIRECTION.NONE:
		#if $BotBox.is_colliding(): # G: I had to fix the node's name to use the proper case. This might not have been an issue on Windows, but it sure was here on Linux.
			#CurrentDir = DIRECTION.RIGHT 
		#if $RgtBox.is_colliding():
			#CurrentDir = DIRECTION.UP 
		#if $LftBox.is_colliding():
			#CurrentDir = DIRECTION.UP 
		
	if CurrentDir == DIRECTION.LEFT:
		velocity.x -= 200
		velocity.y = 0
	
	if CurrentDir == DIRECTION.RIGHT:
		velocity.x = 200
		velocity.y = 0
	
	if CurrentDir == DIRECTION.UP:
		velocity.x = 0
		velocity.y = -200
	
	if CurrentDir == DIRECTION.DOWN:
		velocity.x = 0
		velocity.y = 200
		
	
			
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func kill():
	destroy()

func reflect():
	destroy()
