extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CB_GUERILLA

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
	if GameState.current_weapon != GameState.WEAPONS.GUERRILLA:
		queue_free()

	if CurrentDir == DIRECTION.NONE:
		velocity.x = 100
		velocity.y = 150
		if $BottomCast1.is_colliding() or $BottomCast2.is_colliding():
			CurrentDir = DIRECTION.RIGHT 
			
		if $FrontCast1.is_colliding() or $FrontCast2.is_colliding():
			CurrentDir = DIRECTION.UP 
		
	if CurrentDir == DIRECTION.LEFT:
		velocity.x = -200
		velocity.y = 0
		if !$TopCast1.is_colliding() and !$TopCast2.is_colliding():
			CurrentDir = DIRECTION.DOWN
	
	if CurrentDir == DIRECTION.RIGHT:
		velocity.x = 200
		velocity.y = 0
		if $FrontCast1.is_colliding() or $FrontCast2.is_colliding():
			CurrentDir = DIRECTION.UP 
		if !$BottomCast1.is_colliding() and !$BottomCast2.is_colliding():
			CurrentDir = DIRECTION.DOWN
	
	if CurrentDir == DIRECTION.UP:
		velocity.x = 0
		velocity.y = -200
		if !$FrontCast1.is_colliding() and !$FrontCast2.is_colliding():
			CurrentDir = DIRECTION.RIGHT
			velocity.x = 200
			velocity.y = 0
			
		if $TopCast1.is_colliding() or $TopCast2.is_colliding():
			CurrentDir = DIRECTION.LEFT
			velocity.x = -200
			velocity.y = 0
		
	if CurrentDir == DIRECTION.DOWN:
		velocity.x = 0
		velocity.y = 200
		if $BottomCast1.is_colliding() or $BottomCast2.is_colliding():
			CurrentDir = DIRECTION.RIGHT
			velocity.x = 200
			velocity.y = 0
		if !$BackCast1.is_colliding() and !$BackCast2.is_colliding():
			CurrentDir = DIRECTION.LEFT
			velocity.x = -200
			velocity.y = 0
	
		
	
			
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
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
	destroy()

func reflect():
	destroy()
