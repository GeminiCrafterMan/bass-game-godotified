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
var targetpos : float

#input related
var direction = Vector2.ZERO

#consts
const SPEED = 125.0
const JUMP_VELOCITY = -400.0

#refrences
@onready var state_timer = $StateTimer
@onready var sprite = $AnimatedSprite2D

#other vars
var DmgQueue : int # make the game not crash when you touch an enemy

func _ready():
	#start the teleport animation
	state_timer.start(0.5)
	currentState = STATES.TELEPORT
	sprite.play("Teleport")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		
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
	numberOfTimesToRunStates = 1
	isFirstFrameOfState = false
	while numberOfTimesToRunStates > 0:
		#STATES YOU WANT ANY ANIMATION TO BE CANCELLED WITH LIKE JUMPING AND SHOOTING GO HERE
		#ALWAYS MAKE SURE TELEPORT IS IN THE BLACKLIST SO YOU CANT CANCEL IT
		#other than this, mostly stick to swapping states from inside other states, these are just global cancels
		if (currentState != STATES.NONE) and (currentState != STATES.TELEPORT):
			#check for jump
			if ((Input.is_action_just_pressed("jump") and is_on_floor() and !isFirstFrameOfState)):
				swapState = STATES.JUMP
			#set player to jumping state if not on ground
			if !is_on_floor() and currentState != STATES.JUMP and currentState != STATES.IDLE:
				#we set current state here or else it will acivate first frame which will make the character jump
				currentState = STATES.JUMP
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
				if sprite.animation != "Idle":
					sprite.stop()
					sprite.play("Idle")
				
				#movement of this state
				velocity.x = lerpf(velocity.x, 0, delta * 20)
				#remove any micro-sliding
				if abs(velocity.x) < 1:
					velocity.x = 0
				
				#if inputted, then change state
				if sign(direction.x) != 0:
					swapState = STATES.WALK
			STATES.WALK:
				#there is no step state anymore, the walk just kinda winds-up now
				#the code to do this is silly but not dirty :3 -lynn
				if isFirstFrameOfState:
					sprite.stop()
					#decide wether to have a step or merely kick into the full walk
					if abs(velocity.x) == 0:
						sprite.play("Step")
						state_timer.start(0.1)
					else:
						sprite.play("Walk")
						state_timer.stop()
				if sprite.animation != "Walk" and state_timer.is_stopped():
					sprite.stop()
					sprite.play("Walk")
				#behavior of state
				if direction.x:
					if sprite.animation == "Walk":
						velocity.x = direction.x * SPEED
						sprite.scale.x = sign(-direction.x)
					else:
						velocity.x = (direction.x * SPEED) / 2
						sprite.scale.x = sign(-direction.x)
				
				#exit state if not d-pad
				if direction.x == 0:
					swapState = STATES.IDLE
			
			STATES.JUMP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					velocity.y = JUMP_VELOCITY
				#set animation based on falling for rising
				if velocity.y < 0:
					if sprite.animation != "Jump":
						sprite.stop()
						sprite.play("Jump")
						$Audio/JumpSound.play()
						
				else:
					if sprite.animation != "Jump Transition" and sprite.animation != "Fall":
						sprite.stop()
						sprite.play("Jump Transition")
						state_timer.start(0.1)
						#await sprite.animation_finished <- no using awaits or any kind of wait function in player scripts, causes wierd arcane issues -lynn
					if sprite.animation != "Fall" and state_timer.is_stopped():
						sprite.stop()
						sprite.play("Fall")
				#behavior of state
				if direction.x:
					velocity.x = direction.x * SPEED
					sprite.scale.x = sign(-direction.x)
				else:
					velocity.x = lerpf(velocity.x, 0, delta * 15)
				
				if is_on_floor() and !isFirstFrameOfState:
					$Audio/LandSound.play() #G: ends up playing when you jump, too...?
					swapState = STATES.IDLE
			STATES.SHOOT:
				pass
	
		
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
