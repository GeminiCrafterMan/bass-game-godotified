extends CharacterBody2D

var projectile
var buster_timer : int

var aim : int

# Change the animation with keeping the frame index and progress.
@onready var current_frame = $AnimatedSprite2D.get_frame()
@onready var current_progress = $AnimatedSprite2D.get_frame_progress()

var projectile_scenes = [preload("res://scenes/Objects/Players/Weapons/Bass/buster.tscn")]

# Set these to the name of your action (in the Input Map)
## Name of input action to climb up or generally press up.
@export var input_up : String = "move_up"
## Name of input action to climb down or generally press down.
@export var input_down : String = "move_down"
## Name of input action to move left.
@export var input_left : String = "move_left"
## Name of input action to move right.
@export var input_right : String = "move_right"
## Name of input action to fire the buster.
@export var input_buster : String = "buster"

func _ready():
	$SpawnSound.play()

func _process(delta):
	buster_timer = buster_timer + 1
	current_frame = $AnimatedSprite2D.get_frame()
	current_progress = $AnimatedSprite2D.get_frame_progress()
	
	if (Input.is_action_pressed(input_buster) && Input.is_action_pressed(input_down)):
		$AnimatedSprite2D.play("Down")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		aim = -1
		

	if (Input.is_action_pressed(input_buster) && Input.is_action_pressed(input_up)):
		aim = 1
		$AnimatedSprite2D.play("Diag")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed(input_buster) && Input.is_action_pressed(input_up) && !Input.is_action_pressed(input_left) && !Input.is_action_pressed(input_right)):
		aim = 2
		$AnimatedSprite2D.play("Up")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed(input_buster) && !Input.is_action_pressed(input_down) && !Input.is_action_pressed(input_up)):
		aim = 0
		$AnimatedSprite2D.play("Forward")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed(input_buster) && Input.is_action_pressed(input_left)):
		scale.x = -1
		
	if (Input.is_action_pressed(input_buster) && Input.is_action_pressed(input_right)):
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

