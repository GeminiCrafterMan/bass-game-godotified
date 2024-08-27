extends CharacterBody2D

#signals
signal teleported

#enums
enum STATES {NONE, TELEPORT, IDLE, STEP, WALK, JUMP, SHOOT}

#state related
var currentState = STATES.TELEPORT
var swapState = STATES.NONE
var numberOfTimesToRunStates = 0
var isFirstFrameOfState = false
var targetpos = Vector2.ZERO

#input related
var direction = Vector2.ZERO

#consts
const SPEED = 150.0
const JUMP_VELOCITY = -400.0

#refrences
@onready var state_timer = $StateTimer
@onready var sprite = $AnimatedSprite2D


func _ready():
	#start the teleport animation
	state_timer.start(1)
	currentState = STATES.TELEPORT
	sprite.play("Teleport In")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		
	#INPUTS -lynn
	var direction := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	
	#STATES -lynn
	#always changed states by setting SWAPSTATE almost never set the current_state
	#all states are formatted with a few things
	#1st (optional) do firstframe setup for state, usually starting timers and such
	#2nd the behavior of the state
	#3rd the ways in which the state is exited, either through timers or input
	#sometimes you need to put the exit above the firstFrame of the state
	#depending what it does but dont worry abotu that for now
	numberOfTimesToRunStates = 1
	isFirstFrameOfState = false
	while numberOfTimesToRunStates > 0:
		#STATES YOU WANT ANY ANIMATION TO BE CANCELLED WITH LIKE JUMPING AND SHOOTING GO HERE
		#ALWAYS MAKE SURE TELEPORT IS IN THE BLACKLIST SO YOU CANT CANCEL IT
		if (currentState != STATES.NONE) and (currentState != STATES.TELEPORT):
			#check for jump
			if ((Input.is_action_just_pressed("jump") and is_on_floor() and !isFirstFrameOfState)):
					swapState = STATES.JUMP
			#set player to jumping state if not on ground
			if !is_on_floor() and currentState != STATES.JUMP:
				#we set current state here or else it will acivate first frame which will make the character jump
				currentState = STATES.JUMP
				isFirstFrameOfState = false
				
		match currentState:
			STATES.TELEPORT:
				global_position.x = lerpf(global_position.x, targetpos.x, delta*10)
				global_position.y = lerpf(global_position.y, targetpos.y, delta*10)
				
				#exit teleport
				if state_timer.is_stopped():
					swapState = STATES.IDLE
					teleported.emit()
			
			STATES.IDLE:
				#play animation
				if sprite.animation != "Idle":
					sprite.stop()
					sprite.play("Idle")
				
				#movement of this state
				velocity.x = lerpf(velocity.x, 0, delta * 15)
				
				#if inputted, then change state
				if sign(direction.x) != 0:
					swapState = STATES.STEP
					#back to full speed from a jump (when landing from jump first frame is set to true)
					if isFirstFrameOfState:
						swapState = STATES.WALK
			#im considering getting rid of this state and just merging its functionality into the walk state
			#for simplicity sake, but for now Ill leave it
			#-lynn
			STATES.STEP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					state_timer.start(0.1)
					sprite.stop()
					sprite.play("Step")
					
				if direction.x:
					velocity.x = (SPEED * direction.x) / 2
					sprite.scale.x = sign(-direction.x)
				
				#exit state 1 of 2 ways
				#because walking
				if state_timer.is_stopped() and direction.x:
					swapState = STATES.WALK
				#because let go of d-pad
				if sign(direction.x) == 0:
					swapState = STATES.IDLE
			
			STATES.WALK:
				if sprite.animation != "Walk":
					sprite.stop()
					sprite.play("Walk")
				#behavior of state
				if direction.x:
					velocity.x = direction.x * SPEED
					sprite.scale.x = sign(-direction.x)
				
				#exit state if not d-pad
				if direction.x == 0:
					swapState = STATES.IDLE
			
			STATES.JUMP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					velocity.y = JUMP_VELOCITY
					isFirstFrameOfState = false
				#set animation based on falling for rising
				if velocity.y < 0:
					if sprite.animation != "Jump":
						sprite.stop()
						sprite.play("Jump")
				else:
					if sprite.animation != "Jump Transition":
						sprite.stop()
						sprite.play("Jump Transition")
				#behavior of state
				if direction.x:
					velocity.x = direction.x * SPEED
					sprite.scale.x = sign(-direction.x)
				else:
					velocity.x = lerpf(velocity.x, 0, delta * 15)
				
				if is_on_floor() and !isFirstFrameOfState:
					swapState = STATES.IDLE
			STATES.SHOOT:
				pass
	
		
		#this will boot back into loop if state has changed
		#the reason we do this is so when you do inputs there isnt even a 
		#single frame on input lag, it just immedatley changes state
		#-lynn
		if swapState != STATES.NONE:
			currentState = swapState
			swapState = STATES.NONE
			isFirstFrameOfState = true
			numberOfTimesToRunStates += 1
		numberOfTimesToRunStates -= 1

	move_and_slide()
