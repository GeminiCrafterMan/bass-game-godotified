extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CB_GUERILLA

var state := STATES.SPAWNED
var checker: String 
var direction: int
var explosion = preload("res://scenes/objects/explosion_1.tscn")

enum DIRECTION {
	NONE, 
	LEFT, 
	RIGHT, 
	UP, 
	DOWN
	}

enum STATES{
	SPAWNED,
	DIE,
	CRAWLING
}

var CurrentDir = DIRECTION.NONE

func _ready():
	$SpawnSound.play()

func _physics_process(_delta):
	if GameState.current_weapon != GameState.WEAPONS.GUERRILLA:
		queue_free()
	match state:
		STATES.SPAWNED:
			spawn()
		STATES.DIE:
			pass
	move_and_slide()

func spawn():
	velocity.x = 150 * direction
	velocity.y = 150
	if is_on_floor_only():
		velocity.y = 0
		velocity.x = 150 * direction
	if is_on_wall():
		velocity.x = 0
		velocity.y = -150


	#if CurrentDir == DIRECTION.NONE:
		#velocity.x = 100
		#velocity.y = 150
		#if $BottomCast1.is_colliding() or $BottomCast2.is_colliding():
			#CurrentDir = DIRECTION.RIGHT 
			#
		#if $FrontCast1.is_colliding() or $FrontCast2.is_colliding():
			#CurrentDir = DIRECTION.UP 
		#
	#if CurrentDir == DIRECTION.LEFT:
		#velocity.x = -200
		#velocity.y = 0
		#if !$TopCast1.is_colliding() and !$TopCast2.is_colliding():
			#CurrentDir = DIRECTION.DOWN
	#
	#if CurrentDir == DIRECTION.RIGHT:
		#velocity.x = 200
		#velocity.y = 0
		#if $FrontCast1.is_colliding() or $FrontCast2.is_colliding():
			#CurrentDir = DIRECTION.UP 
		#if !$BottomCast1.is_colliding() and !$BottomCast2.is_colliding():
			#CurrentDir = DIRECTION.DOWN
	#
	#if CurrentDir == DIRECTION.UP:
		#velocity.x = 0
		#velocity.y = -200
		#if !$FrontCast1.is_colliding() and !$FrontCast2.is_colliding():
			#CurrentDir = DIRECTION.RIGHT
			#velocity.x = 200
			#velocity.y = 0
			#
		#if $TopCast1.is_colliding() or $TopCast2.is_colliding():
			#CurrentDir = DIRECTION.LEFT
			#velocity.x = -200
			#velocity.y = 0
		#
	#if CurrentDir == DIRECTION.DOWN:
		#velocity.x = 0
		#velocity.y = 200
		#if $BottomCast1.is_colliding() or $BottomCast2.is_colliding():
			#CurrentDir = DIRECTION.RIGHT
			#velocity.x = 200
			#velocity.y = 0
		#if !$BackCast1.is_colliding() and !$BackCast2.is_colliding():
			#CurrentDir = DIRECTION.LEFT
			#velocity.x = -200
			#velocity.y = 0
	#
		#
	#
			#
	#move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()
	print("del bomb")

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	state = STATES.DIE
	velocity.x = 0
	velocity.y = 0
	GameState.onscreen_sp_bullets -= 1
	$AnimatedSprite2D.play("hit")
	var exp = explosion.instantiate()
	add_child(exp)
	await $AnimatedSprite2D.animation_finished
	queue_free()

func kill():
	destroy()

func reflect():
	destroy()
