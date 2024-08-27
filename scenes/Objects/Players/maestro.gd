extends CharacterBody2D

#enums
enum STATES {NONE, IDLE, STEP, WALK, JUMP, SHOOT}

#state related
var currentState = STATES.IDLE
var swapState = STATES.NONE
var numberOfTimesToRunStates = 0
var isFirstFrameOfState = false

#input related
var direction = Vector2.ZERO

#consts
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

#refrences
@onready var state_timer = $StateTimer


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
		
		
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
		match currentState:
			STATES.IDLE:
				#movement of this state
				velocity.x = move_toward(velocity.x, 0, delta * 10)
				
				#if inputted, then change state
				if direction.x:
					swapState = STATES.STEP
				
			STATES.STEP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					state_timer.start(0.1)
					
				#movement of this state
				velocity.x = direction.x * SPEED / 2
				
				#exit state 1 of 2 ways
				#because walking
				if state_timer.is_stopped() and direction.x:
					swapState = STATES.WALK
				#because let go of d-pad
				if !direction.x:
					swapState = STATES.IDLE
			
			STATES.WALK:
				#behavior of state
				velocity.x = direction.x * SPEED
				
				#exit state if not d-pad
				if !direction.x:
					swapState = STATES.IDLE
	
		
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
