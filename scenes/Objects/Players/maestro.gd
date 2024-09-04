extends CharacterBody2D

#signals
signal teleported

#enums
enum STATES {
	NONE, 
	TELEPORT, 
	IDLE, 
	STEP, 
	WALK, 
	SLIDE,
	JUMP, 
	HURT
	}

#state related
var currentState = STATES.TELEPORT
var swapState = STATES.NONE
var numberOfTimesToRunStates = 0
var isFirstFrameOfState = false
var targetpos : float
var currentSpeed = 0
#input related
var direction = Vector2.ZERO

#consts
const MAXSPEED = 100.0
const RUNSPEED = 70.0
const JUMP_VELOCITY = -225.0
const PEAK_VELOCITY = -100.0
const STOP_VELOCITY = -80.0
const JUMP_HEIGHT = 13
const FAST_FALL = 400.0

#refrences
@onready var state_timer = $StateTimer
@onready var sprite = $AnimatedSprite2D
@onready var FX

#other vars
var DmgQueue : int # make the game not crash when you touch an enemy
var JumpHeight : int #How long you're holding the jump button to go higher
var StepTime : int #How long you're stepping
var SlideTimer : int
var PainTimer : int
var InvincFrames : int

func _ready():
	#start the teleport animation
	state_timer.start(0.5)
	currentState = STATES.TELEPORT
	sprite.play("Teleport")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if GameState.current_hp <= 0:
		GameState.current_hp = 28 # Add death function later!

	if ($CeilingCheck.is_colliding() == false or currentState != STATES.SLIDE):
		_DamageAndInvincible()
	
	if velocity.y > FAST_FALL:
		velocity.y = FAST_FALL
		
	if currentState != STATES.SLIDE:
		SlideTimer = 0
		$MainHitbox.set_disabled(false)
		$SlideHitbox.set_disabled(true)
		
		
	#INPUTS -lynn
	var direction := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	#this cancels out any floats in the inputs and 
	#makes inputs to be purely digital (-1,0,1) rather than analouge
	direction = Vector2(sign(direction.x), sign(direction.y))
	
	#STATES -lynn
	#always changed states by setting SWAPSTATE almost never set the current_state
	#all states are formatted with a few things
	#1st (optional) do firstframe setup for state, usually starting timers and such
	#2nd the behavior of the state
	#3rd the ways in which the state is exited, either through timers or input
	#sometimes you need to put the exit above the firstFrame of the state
	#depending what it does but dont worry abotu that for now
	#EXTRA NOTE using a check for what the current animation is before setting a new one is a good
	#way to tell what animation you are coming from and can add special code for when doing so
	#good example is in the jump state I check if you are coming in from the shoot state and set the anim accordingly
	numberOfTimesToRunStates = 1
	isFirstFrameOfState = false
	while numberOfTimesToRunStates > 0:
		#STATES YOU WANT ANY ANIMATION TO BE CANCELLED WITH LIKE JUMPING AND SHOOTING GO HERE
		#ALWAYS MAKE SURE TELEPORT IS IN THE BLACKLIST SO YOU CANT CANCEL IT
		#other than this, mostly stick to swapping states from inside other states, these are just global cancels
		if (currentState != STATES.NONE) and (currentState != STATES.TELEPORT):
			
			#check for jump
			if ((Input.is_action_just_pressed("jump") and is_on_floor() and !isFirstFrameOfState) and currentState != STATES.HURT):
				if ($CeilingCheck.is_colliding() == false or currentState != STATES.SLIDE):
					swapState = STATES.JUMP
					StepTime = 7
			#set player to jumping state if not on ground
			if !is_on_floor() and currentState != STATES.JUMP and currentState != STATES.HURT:
				#we set current state here or else it will acivate first frame which will make the character jump
				currentState = STATES.JUMP
				swapState = STATES.NONE
				isFirstFrameOfState = false
				
		match currentState:
			STATES.TELEPORT:
#				global_position.x = targetpos.x
				global_position.y = lerpf(global_position.y, targetpos, delta * 10)
				
				#exit teleport
				if roundi(global_position.y) == roundi(targetpos):
					if not sprite.animation == "Teleport In":
						sprite.play("Teleport In")
						$Audio/WarpInSound.play()
						await sprite.animation_finished
						swapState = STATES.IDLE
						teleported.emit()
			
			STATES.IDLE:
				#play animation
				if StepTime > 0:
					StepTime -= 1
					if sprite.animation != "Step":
						sprite.stop()
						sprite.play("Step")
				
				else:
					if sprite.animation != "Idle":
						sprite.stop()
						sprite.play("Idle")
						
				if Input.is_action_pressed("move_down") && Input.is_action_just_pressed("jump"):
					swapState = STATES.SLIDE
				
				#movement of this state
				default_movement(direction, delta)
				#if inputted, then change state
				if sign(direction.x) != 0:
					swapState = STATES.WALK
			STATES.WALK:
				#there is no step state anymore, the walk just kinda winds-up now
				#the code to do this is silly but not dirty :3 -lynn
				if Input.is_action_pressed("move_down") && Input.is_action_just_pressed("jump"):
					swapState = STATES.SLIDE
				
				if StepTime > 6:
					if sprite.animation != "Walk":
						var progress = sprite.get_frame_progress()
						var frame = sprite.get_frame()
						sprite.play("Walk")
						sprite.set_frame_and_progress(frame, progress)
				else:
					if sprite.animation != "Step":
						sprite.stop()
						sprite.play("Step")
				#behavior of state
				default_movement(direction, delta)
				
				#exit state if not d-pad
				if direction.x == 0:
					if StepTime > 0:
						StepTime -= 1
						if sprite.animation != "Step":
							sprite.stop()
							sprite.play("Step")
		
						swapState = STATES.IDLE
			STATES.SLIDE:
				if isFirstFrameOfState:
					$Audio/SlideSound.play()
					if sprite.animation != "Slide":
							sprite.stop()
							sprite.play("Slide")
					#Changes Collision
					$MainHitbox.set_disabled(true)
					$SlideHitbox.set_disabled(false)
					
					#Spawns Smoke
					FX = preload("res://scenes/Objects/Players/dashtrail.tscn").instantiate()
					get_parent().add_child(FX)
					if sprite.scale.x == 1:
						FX.scale.x = -1
						FX.position.x = position.x + 15
					else:
						FX.position.x = position.x - 15
					FX.position.y = position.y+8
					
				if SlideTimer > 24:
					
					if $CeilingCheck.is_colliding() == false:
						#Changes to normal state.Rest is handled normally
						swapState = STATES.IDLE
				else:
					SlideTimer += 1
					
				velocity.x = -sprite.scale.x * 200
				
				if $CeilingCheck.is_colliding() == false:
					if isFirstFrameOfState == false:
						if (direction.x == -1 && sprite.scale.x == -1 or direction.x == 1 && sprite.scale.x == 1):
							swapState = STATES.WALK
					
				
				if $CeilingCheck.is_colliding() == true:
					if direction.x:
						sprite.scale.x = sign(-direction.x)
					
				
			STATES.JUMP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					velocity.y = JUMP_VELOCITY
				#if coming in from the shoot animation, set immediatley to falling animation
				if sprite.animation == "Jump-Shoot":
					sprite.stop()
					sprite.play("Fall")
				#set animation based on falling for rising
				if velocity.y < 0:
					
					if (JumpHeight < JUMP_HEIGHT && Input.is_action_pressed("jump")):
						velocity.y = JUMP_VELOCITY
						JumpHeight += 1
						
					if (JumpHeight == JUMP_HEIGHT):
						JumpHeight = 80
						velocity.y = PEAK_VELOCITY
						
					if (Input.is_action_just_released("jump")):
						JumpHeight = 80
						velocity.y = STOP_VELOCITY
						
						
					
					if sprite.animation != "Jump":
						sprite.stop()
						sprite.play("Jump")
						$Audio/JumpSound.play()
						
				else:
					if sprite.animation != "Jump Transition" and sprite.animation != "Fall":
						JumpHeight = 0
						sprite.stop()
						sprite.play("Jump Transition")
						state_timer.start(0.1)
						#await sprite.animation_finished <- no using awaits or any kind of wait function in player scripts, causes wierd arcane issues -lynn
					if sprite.animation != "Fall" and state_timer.is_stopped():
						sprite.stop()
						sprite.play("Fall")
				#behavior of state
				#movement in state
				default_movement(direction, delta)
				
				if is_on_floor() and !isFirstFrameOfState:
					$Audio/LandSound.play() #G: ends up playing when you jump, too...?
					swapState = STATES.IDLE
				
			STATES.HURT:
				if isFirstFrameOfState:
					$Audio/HurtSound.play()
					if sprite.animation != "Hurt":
							sprite.stop()
							sprite.play("Hurt")
				if PainTimer == 0:
					swapState = STATES.IDLE
				else:
					PainTimer -= 1
					velocity.x = sprite.scale.x * 20
					
				if isFirstFrameOfState == true:
					if is_on_floor():
						velocity.y = -70
					else:
						velocity.y = -90
					
		
		#this will boot back into loop if state has changed
		#the reason we do this is so when you do inputs there isnt even a 
		#single frame on input lag, it just immedatley changes state within the current cycle
		#-lynn
		if swapState != STATES.NONE:
			print("changed state to: " + str(swapState))
			currentState = swapState
			swapState = STATES.NONE
			isFirstFrameOfState = true
			numberOfTimesToRunStates += 1
			
		numberOfTimesToRunStates -= 1
	move_and_slide()


func default_movement(direction, delta):
	#movement in state
	if direction.x:
		
		sprite.scale.x = sign(-direction.x)
		
		if StepTime < 6:
			if StepTime < 1:
				position.x = position.x + direction.x
			StepTime += 1
		
		else:
			StepTime = 7
			if (sprite.scale.x != sign(-direction.x)) and currentSpeed != 0:
				currentSpeed = MAXSPEED
			currentSpeed = lerpf(currentSpeed, MAXSPEED, delta * 20)
			#no crazy floats because lerp
			if abs(currentSpeed) > MAXSPEED - (MAXSPEED / 100):
				currentSpeed = MAXSPEED
			#shmoovve
			
	else:
		#come to stop (Megaman Should only do this on ice)
		#currentSpeed = lerpf(currentSpeed, 0, delta * 25)
		#no crazy floats because lerp
			
		currentSpeed = 0
		
		
	velocity.x = -sprite.scale.x * currentSpeed

func _DamageAndInvincible():
	if InvincFrames > 0:
		InvincFrames -= 1
		if InvincFrames % 2 == 0:
			visible = false
		else:
			visible = true
	else:
		visible = true
	if DmgQueue > 0:
		if InvincFrames > 0:
			DmgQueue = 0
		else:
			if GameState.current_hp - DmgQueue > 0:
				GameState.current_hp -= DmgQueue
			else:
				GameState.current_hp = 0
			DmgQueue = 0
			swapState = STATES.HURT
			PainTimer = 35
