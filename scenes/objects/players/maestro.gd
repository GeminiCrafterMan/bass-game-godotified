extends CharacterBody2D

class_name MaestroPlayer

#region Signals
signal teleported
#endregion

#region Enums
enum STATES {
	NONE,
	TELEPORT,
	IDLE,
	STEP,
	WALK,
	SLIDE,
	JUMP,
	LADDER,
	HURT,
	DEAD
}
#endregion

# state related
var currentState := STATES.TELEPORT
var swapState := STATES.NONE
var numberOfTimesToRunStates := 0
var isFirstFrameOfState := false
var targetpos : float
var currentSpeed := 0
var fallstored : float
#input related


#region Exports
# input related
@export var JUMP_VELOCITY: int = -225
@export var PEAK_VELOCITY: int = -90
@export var STOP_VELOCITY: int = -80
@export var JUMP_HEIGHT: int = 13
@export var FAST_FALL: int = 400
@export var MAXSPEED: int = 100
@export var RUNSPEED: int = 70
#endregion

var transing : bool = false

#consts
const EXPLOSION_SPEEDS : Array[Vector2] = [ #G: Hey look, I can actually pretty much just copy what I had for the Genesis version...
# G (but from the Genesis): okay this kind of makes no sense but it also works to help visualize the orbs
								Vector2(0, -150),
		Vector2(-100, -100),						Vector2(100, -100),
								Vector2(0, -50),
	Vector2(-150, 0),	Vector2(-50, 0),	Vector2(50, 0),	Vector2(150, 0),
								Vector2(0, 50),
		Vector2(-100, 100),							Vector2(100, 100),
								Vector2(0, 150)
]
# weapon constants
const ORIGAMI_SPEED := 350
const CRACKER_SPEED := 450

#region References
@onready var ladder_check: ShapeCast2D = $LadderCheck
@onready var top_ladder_check: ShapeCast2D = $TopLadderCheck
@onready var state_timer: Timer = $StateTimer
@onready var invul_timer: Timer = $InvulTimer
@onready var pain_timer: Timer = $PainTimer
@onready var slide_timer: Timer = $SlideTimer
@onready var attack_timer: Timer = $FireDelay
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var starburst: AnimatedSprite2D = $FX/Starburst
@onready var sweat: AnimatedSprite2D = $FX/Sweat
@onready var FX: Node2D
@onready var projectile
@onready var shield
@onready var shield2
@onready var shield3
@onready var shield4
#endregion

#other vars
var DmgQueue : int # make the game not crash when you touch an enemy
var JumpHeight : int #How long you're holding the jump button to go higher
var StepTime : int #How long you're stepping
var PainTimer : int
var InvincFrames : int
var Charge : int
var ScytheCharge : int
var Flash_Timer : int
var progress : float
var no_grounded_movement : bool
var in_water : bool
var on_ice : bool
var ice_jump : bool

#Attack vars
var shot_type = 0

var weapon_palette: Array[Texture2D] = [
	preload("res://sprites/players/maestro/palettes/Maestro Buster.png"),
	preload("res://sprites/players/maestro/palettes/Scorch Barrier.png"),
	preload("res://sprites/players/maestro/palettes/Track 2.png"),
	preload("res://sprites/players/maestro/palettes/Poison Cloud.png"),
	preload("res://sprites/players/maestro/palettes/Fin Shredder.png"),
	preload("res://sprites/players/maestro/palettes/Origami Star.png"),
	preload("res://sprites/players/maestro/palettes/Wild Gale.png"),
	preload("res://sprites/players/maestro/palettes/Rolling Bomb.png"),
	preload("res://sprites/players/maestro/palettes/Boomerang Scythe.png"),
	preload("res://sprites/players/maestro/palettes/Maestro Buster.png"), # Proto Shield
	preload("res://sprites/players/maestro/palettes/Treble.png"), # "Treble Boost" (skip it)
	preload("res://sprites/players/maestro/palettes/Carry.png"),
	preload("res://sprites/players/maestro/palettes/Super Arrow.png"),
	preload("res://sprites/players/maestro/palettes/Mirror Buster.png"),
	preload("res://sprites/players/maestro/palettes/Screw Crusher.png"),
	preload("res://sprites/players/maestro/palettes/Ballade Cracker.png"),
	preload("res://sprites/players/maestro/palettes/Sakugarne.png"),
	preload("res://sprites/players/maestro/palettes/ChargeX1.png"),
	preload("res://sprites/players/maestro/palettes/ChargeX2.png"),
	preload("res://sprites/players/weapons/ScytheCharge0.png"),
	preload("res://sprites/players/weapons/ScytheCharge1.png")
]

var projectile_scenes = [
	preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/carry.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/arrow.tscn")
]

var weapon_scenes = [
	preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn")
]

func _ready():
	GameState.player = self

	# start the teleport animation
	GameState.onscreen_bullets = 0
	GameState.onscreen_sp_bullets = 0
	state_timer.start(0.5)
	invul_timer.start(0.01)
	currentState = STATES.TELEPORT
	anim.play("Teleport")

func _physics_process(delta: float) -> void:
	progress = anim.get_current_animation_position()

	GameState.player.position.x = position.x
	GameState.player.position.y = position.y

	if GameState.onscreen_sp_bullets < 0:
		GameState.onscreen_sp_bullets = 0

	if GameState.onscreen_bullets < 0:
		GameState.onscreen_bullets = 0


	if GameState.current_hp > 28:
		GameState.current_hp = 28
	if GameState.weapon_energy[GameState.current_weapon] > GameState.max_weapon_energy[GameState.current_weapon]:
		GameState.weapon_energy[GameState.current_weapon] = GameState.max_weapon_energy[GameState.current_weapon]


	# Add the gravity.
	if transing != true:
		if (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
			if not is_on_floor():
				velocity += get_gravity() * delta
				if fallstored != 0:
					velocity.y = fallstored
					fallstored = 0
	else:
		if velocity.y != 0:
			fallstored = velocity.y
			velocity.y = 0
		
		
		

	if GameState.current_hp <= 0 && currentState != STATES.DEAD:
		swapState = STATES.DEAD

	if shield != null:
		shield.baseposx = position.x + sprite.scale.x * 1
		shield.baseposy = position.y+4

	if shield2 != null:
		shield2.baseposx = position.x + sprite.scale.x * 1
		shield2.baseposy = position.y+4

	if shield3 != null:
		shield3.baseposx = position.x + sprite.scale.x * 1
		shield3.baseposy = position.y+4

	if shield4 != null:
		shield4.baseposx = position.x + sprite.scale.x * 1
		shield4.baseposy = position.y+4

	if currentState != STATES.TELEPORT:
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && currentState != STATES.HURT && currentState != STATES.DEAD:
			handle_weapons()

		if Input.is_action_just_pressed("switch_right"):
			if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
				GameState.old_weapon = GameState.current_weapon

				if (GameState.current_weapon == GameState.WEAPONS.QUINT):
					GameState.current_weapon = GameState.WEAPONS.BUSTER
				else:
					GameState.current_weapon += 1

					if (GameState.current_weapon != GameState.WEAPONS.BUSTER):
						while (GameState.weapons_unlocked[GameState.current_weapon] == false):
							if (GameState.current_weapon == GameState.WEAPONS.QUINT && GameState.weapons_unlocked[GameState.WEAPONS.QUINT] == false):
								GameState.current_weapon = GameState.WEAPONS.BUSTER
							else:
								GameState.current_weapon += 1


		if Input.is_action_just_pressed("switch_left"):
			if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
				GameState.old_weapon = GameState.current_weapon

				if (GameState.current_weapon == GameState.WEAPONS.BUSTER):
					GameState.current_weapon = GameState.WEAPONS.QUINT
				else:
					GameState.current_weapon -= 1

				while (GameState.weapons_unlocked[GameState.current_weapon] == false):
					GameState.current_weapon -= 1


	if GameState.old_weapon != GameState.current_weapon:
		GameState.onscreen_sp_bullets = 0
		SoundManager.play("player", "switch")
		GameState.old_weapon = GameState.current_weapon
		set_current_weapon_palette()

	if  (Input.is_action_just_pressed("switch_left") && Input.is_action_pressed("switch_right")) or (Input.is_action_pressed("switch_left") && Input.is_action_just_pressed("switch_right")):
		if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
			GameState.current_weapon = GameState.WEAPONS.BUSTER
			if GameState.old_weapon != GameState.current_weapon:
				SoundManager.play("player", "switch")
				GameState.onscreen_sp_bullets = 0
			set_current_weapon_palette()



	if ($CeilingCheck.is_colliding() == false or (currentState != STATES.SLIDE) and (currentState != STATES.HURT)):
		_DamageAndInvincible()

	if velocity.y > FAST_FALL:
		velocity.y = FAST_FALL

	if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
		$MainHitbox.set_disabled(false)
		$SlideHitbox.set_disabled(true)
	
	if transing != true:
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
			if  (currentState != STATES.NONE) and (currentState != STATES.TELEPORT) and (currentState != STATES.DEAD):
				#check for ladder
				if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and  sign(direction.y) != 0:
					if (ladder_check.is_colliding() or top_ladder_check.is_colliding()) and !Input.is_action_pressed("jump"):
						for i in ladder_check.get_collision_count():
							if ladder_check.get_collider(i).is_in_group("ladder"):
								if !(is_on_floor() and Input.is_action_pressed("move_down")):
									global_position.x = ladder_check.get_collider(i).global_position.x
									currentState = STATES.LADDER
									# G: shut the FUCK UP x2
									#print("Ladder'd")
									swapState = STATES.NONE
									isFirstFrameOfState = false
								else:
									global_position.y += 1
	
	
	
	
				#check for jump
				if ((Input.is_action_just_pressed("jump") and is_on_floor() and (!isFirstFrameOfState or (currentState == STATES.IDLE or currentState == STATES.WALK)) and currentState != STATES.HURT and currentState != STATES.LADDER and currentState != STATES.DEAD)):
					if ($CeilingCheck.is_colliding() == false or (currentState != STATES.SLIDE) and (currentState != STATES.HURT)):
						swapState = STATES.JUMP
						if on_ice == true:
							ice_jump = true
						StepTime = 0
						JumpHeight = 0
	
				#set player to jumping state if not on ground
				if !is_on_floor() and currentState != STATES.JUMP and currentState != STATES.HURT and currentState != STATES.LADDER and currentState != STATES.DEAD:
					#we set current state here or else it will acivate first frame which will make the character jump
					StepTime = 0
					currentState = STATES.JUMP
					swapState = STATES.NONE
					if on_ice == true:
							ice_jump = true
					isFirstFrameOfState = false
	
			match currentState:
				STATES.TELEPORT:
					state_teleport(direction, delta)
				STATES.IDLE:
					state_idle(direction, delta)
				STATES.WALK:
					state_walk(direction, delta)
				STATES.SLIDE:
					state_slide(direction, delta)
				STATES.JUMP:
					state_jump(direction, delta)
				STATES.LADDER:
					state_ladder(direction, delta)
				STATES.HURT:
					state_hurt(direction, delta)
				STATES.DEAD:
					state_dead(direction, delta)
	
			#this will boot back into loop if state has changed
			#the reason we do this is so when you do inputs there isnt even a
			#single frame on input lag, it just immedatley changes state within the current cycle
			#-lynn
			if swapState != STATES.NONE:
				# G: shut the FUCK UP
				#print("changed state to: " + str(swapState))
				currentState = swapState
				swapState = STATES.NONE
				isFirstFrameOfState = true
				numberOfTimesToRunStates += 1
	
			numberOfTimesToRunStates -= 1
		move_and_slide()
	if (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
		weapon_buster()
		do_charge_palette()
		scythe_charge_palette()

#region States
## Teleport state
func state_teleport(_direction: Vector2, _delta: float) -> void:
	teleport()

## Idle state
func state_idle(_direction: Vector2, _delta: float) -> void:
	#play animation
	if attack_timer.is_stopped():
		if StepTime > 0:
			StepTime -= 1
			if anim.get_current_animation() != "Step":
				anim.stop()
				anim.play("Step")
		else:
			if anim.get_current_animation() != "Idle":
				anim.stop()
				anim.play("Idle")
	else:
		match shot_type:
			0: # Normal
				anim.play("Idle-Shoot")
			1: # StopShoot
				anim.play("Idle-Shoot")
			2: # Throw
				anim.play("Idle-Throw")
			3: # Shield
				anim.play("Idle-Shield")
			4: # Fin Shredder
				anim.play("FinShredder")
			5: # Shredder2
				anim.play("DoubleFinShredder")
			_: # Everything else
				anim.play("Idle-Shoot")
	if (Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump")) or (Input.is_action_just_pressed("dash")):
		swapState = STATES.SLIDE

	#movement of this state
	default_movement(_direction, _delta)
	#if inputted, then change state
	if sign(_direction.x) != 0:
		swapState = STATES.WALK

## Walk state
func state_walk(_direction: Vector2, _delta: float) -> void:
	#there is no step state anymore, the walk just kinda winds-up now
	#the code to do this is silly but not dirty :3 -lynn
	if (Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump")) or (Input.is_action_just_pressed("dash")):
		swapState = STATES.SLIDE

	if !attack_timer.is_stopped():
		match shot_type:
			0: # Normal
				anim.play("Walk-Shoot")
				anim.seek(progress)
			1: # Stop
				anim.play("Idle-Shoot")
			2: # Throw
				anim.play("Idle-Throw")
			3: # Shield
				anim.play("Idle-Shield")
			4: # Shredder
				anim.play("FinShredder")
			5: # Shredder2
				anim.play("DoubleFinShredder")
			_: # Everything else
				anim.play("Walk-Shoot")
				anim.seek(progress)
	else:
		if StepTime > 6:
			anim.play("Walk")
			anim.seek(progress)
		else:
			if anim.get_current_animation() != "Step":
				anim.stop()
				anim.play("Step")
	#behavior of state
	default_movement(_direction, _delta)

	#exit state if not d-pad
	if _direction.x == 0:
		if StepTime > 0:
			StepTime -= 1
			if anim.get_current_animation() != "Step":
				anim.stop()
				anim.play("Step")
			swapState = STATES.IDLE

## Slide state
func state_slide(_direction: Vector2, _delta: float) -> void:
	if isFirstFrameOfState:
		slide_timer.start()
		SoundManager.play("player", "slide")
		if anim.get_current_animation() != "Slide":
			anim.stop()
			anim.play("Slide")
		#Changes Collision
		$MainHitbox.set_disabled(true)
		$SlideHitbox.set_disabled(false)
		#Spawns Smoke
		FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
		get_parent().add_child(FX)
		if sprite.scale.x == -1:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8

	if slide_timer.is_stopped():
		if $CeilingCheck.is_colliding() == false:
			#Changes to normal state.Rest is handled normally
			swapState = STATES.IDLE
			slide_timer.start()

	if on_ice == false:
		velocity.x = sprite.scale.x * 200
	else:
		velocity.x = lerpf(velocity.x, sprite.scale.x * 250, _delta * 4)

	if $CeilingCheck.is_colliding() == false:
		if isFirstFrameOfState == false:
			if sign(_direction.x) == sign(-sprite.scale.x):
				swapState = STATES.WALK
	else:
		if _direction.x:
			sprite.scale.x = sign(_direction.x)

## Jump state
func state_jump(_direction: Vector2, _delta: float) -> void:
	#setup needed on first frame of new state
	if isFirstFrameOfState:
		velocity.y = JUMP_VELOCITY
	#if coming in from the shoot animation, set immediatley to falling animation
	if anim.get_current_animation() == "Jump-Shoot":
		anim.stop()
		anim.play("Fall")
	#set animation based on falling for rising
	if velocity.y < 0 && JumpHeight != 80:
		if (JumpHeight < JUMP_HEIGHT && Input.is_action_pressed("jump")):
			velocity.y = JUMP_VELOCITY
			JumpHeight += 1
		if (JumpHeight == JUMP_HEIGHT):
			JumpHeight = 80
			velocity.y = PEAK_VELOCITY
		if (Input.is_action_just_released("jump")):
			JumpHeight = 80
			velocity.y = STOP_VELOCITY
		if isFirstFrameOfState:
			if attack_timer.is_stopped():
				anim.stop()
				anim.play("Jump")
			SoundManager.play("player", "jump")
	else:
		if attack_timer.is_stopped():
			if StepTime < 7:
				StepTime += 1
				anim.play("Jump Transition")
			else:
				anim.play("Fall")

	if !attack_timer.is_stopped():
		match shot_type:
			0: # Normal
				anim.play("Jump-Shoot")
			1: # Normal
				anim.play("Jump-Shoot")
			2: # Throw
				anim.play("Jump-Throw")
			3: # Shield
				anim.play("Jump-Shield")
			4: # Shredder
				anim.play("Jump-Throw")
			5: # Shredder2
				anim.play("Jump-Throw")
			_: # Everything else
				anim.play("Jump-Shoot")

	#behavior of state
	#movement in state
	if ice_jump == false:
		default_movement(_direction, _delta)
	else:
		ice_jump_move(_direction, _delta)

	if is_on_floor() and !isFirstFrameOfState:
		SoundManager.play("player", "land")
		swapState = STATES.IDLE
		if on_ice == false:
			ice_jump = false

## Ladder state
func state_ladder(_direction: Vector2, _delta: float) -> void:
	if !attack_timer.is_stopped() or Input.is_action_just_pressed("buster") or Input.is_action_just_pressed("shoot"):
		if _direction.x != 0:
			sprite.scale.x = sign(_direction.x)
		if anim.get_current_animation() != "Ladder-Shoot":
			anim.play("Ladder-Shoot")
	else:
		if anim.get_current_animation() != "Ladder":
			anim.play("Ladder")
		else:
			#pause and play ladder animation
			if _direction.y != 0:
				anim.play()
			else:
				anim.pause()

	#movement
	velocity.x = 0
	#THIS IS THE SPEED OF THE LADDER
	#remove this if statement to allow moving while shooting on ladders
	if attack_timer.is_stopped():
		velocity.y = sign(_direction.y) * -100
	else:
		velocity.y = 0

	#this is a weird way to do this but whatever man lol
	#check to see if still on ladder -lynn
	var stillLadder = false
	if ladder_check.is_colliding():
		for i in ladder_check.get_collision_count():
			if ladder_check.get_collider(i).is_in_group("ladder"):
				stillLadder = true

	if (stillLadder == false) or (Input.is_action_just_pressed("jump")) or (is_on_floor() and Input.is_action_pressed("move_down")):
		currentState = STATES.IDLE
		velocity.y = 0

## Hurt state
func state_hurt(_direction: Vector2, _delta: float) -> void:
	if isFirstFrameOfState:
		if GameState.current_hp <= 0:
			swapState = STATES.DEAD
		starburst.visible = true
		sweat.play("active")
		sweat.set_frame_and_progress(0, 0)
		if GameState.current_hp > 0:
			SoundManager.play("player", "hurt")
		if anim.get_current_animation() != "Hurt":
			anim.stop()
			anim.play("Hurt")
	if pain_timer.is_stopped():
		swapState = STATES.IDLE
		starburst.visible = false
	else:
		velocity.x = sprite.scale.x * -20
	if isFirstFrameOfState == true:
		if is_on_floor():
			velocity.y = -70
		else:
			velocity.y = -90

## Death state
func state_dead(_direction: Vector2, _delta: float) -> void:
	if isFirstFrameOfState:
		# G: queue_free-ing these because otherwise stuff like Tellies can *double* kill you.
		$MainHitbox.set_disabled(true)
		$SlideHitbox.set_disabled(true)
		state_timer.start(5.00)
		anim.play("Dead")
		velocity.y = 0
		velocity.x = 0
	if pain_timer.is_stopped():
		SoundManager.play("player", "death")
		scale = Vector2.ZERO
		for i in 12:
			projectile = preload("res://scenes/objects/explosion_player.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.velocity = EXPLOSION_SPEEDS[i]
		pain_timer.start(2550)
	if state_timer.is_stopped():
		sprite.visible = false
		Fade.fade_out()
		#await Fade.fade_out().finished # G: Seems to not work
		GameState.player_lives -= 1
		#Reset the stage
		reset(false)
		get_tree().reload_current_scene()
#endregion States

# ==================
# MOVEMENT FUNCTIONS
# ==================
func default_movement(direction, delta):
	#movement in state
	if direction.x and (no_grounded_movement == false or is_on_floor() == false):

		if is_on_floor() == true && no_grounded_movement == true:
			if on_ice == false:
				currentSpeed = 0

		else:
			sprite.scale.x = sign(direction.x)

			if StepTime < 6 && currentState != STATES.JUMP:
				if StepTime < 1:
					if is_on_floor() == true && on_ice == false:
						position.x = position.x + direction.x
				StepTime += 1

			else:
				if currentState != STATES.JUMP:
					StepTime = 7
				if (sprite.scale.x != sign(direction.x)) and currentSpeed != 0:
					if is_on_floor() == true && on_ice == true:
						if velocity.x <= -MAXSPEED && velocity.x >= MAXSPEED:
							velocity.x = lerpf(velocity.x, direction.x * MAXSPEED, delta * 3)
					else:
						currentSpeed = MAXSPEED

				if is_on_floor() == true && on_ice == true:
					velocity.x = lerpf(velocity.x, direction.x * MAXSPEED*1.5, delta * 2)

				else:
					currentSpeed = MAXSPEED
				#shmoovve

	else:
		if is_on_floor() == false or on_ice == false:
			currentSpeed = 0
		else:
			velocity.x = lerpf(velocity.x, 0, delta * 2)

	if on_ice == false:
		velocity.x = sprite.scale.x * currentSpeed

func ice_jump_move(direction, delta):
	#movement in state

	if direction.x:
		sprite.scale.x = sign(direction.x)

		if (direction.x == -1 && velocity.x > 20) or (direction.x == 1 && velocity.x < -20):
			velocity.x = lerpf(velocity.x, 0, delta * 7)
		else:
			if (direction.x == 1 && velocity.x < 30) or (direction.x == -1 && velocity.x > -30):
				velocity.x = lerpf(direction.x * 50, 0, delta * 7)

	else:
		velocity.x = lerpf(velocity.x, 0, delta * 4)

#region Weapons
func do_charge_palette():
	if Charge == 0 or Charge < 37: # no charge
		set_current_weapon_palette()
	elif Charge >= 37 && Charge < 65: # just started charging
		if Flash_Timer == 2 || Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[17])
			Flash_Timer += 1
		else:
			set_current_weapon_palette()
			Flash_Timer += 1
		if Flash_Timer == 3:
			Flash_Timer = 0
	elif Charge >= 65 && Charge < 92:
		if Flash_Timer == 1:
			sprite.material.set_shader_parameter("palette",weapon_palette[17])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer = 1
	elif Charge >= 92:
		if Flash_Timer == 1:
			sprite.material.set_shader_parameter("palette",weapon_palette[18])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer = 1

func scythe_charge_palette():
	if ScytheCharge > 0:
		Charge = 0
	if GameState.current_weapon != GameState.WEAPONS.REAPER:
		ScytheCharge = 0
	if ScytheCharge > 0 and ScytheCharge < 35: # no charge
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[19])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer += 1


	elif ScytheCharge >= 35 && ScytheCharge < 75: # just started charging
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[20])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer += 1


	elif ScytheCharge >= 75:
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[19])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[20])
			Flash_Timer += 1

func handle_weapons():
	if !attack_timer.is_stopped():
		if shot_type > 0:
			no_grounded_movement = true
	else:
		no_grounded_movement = false

	match GameState.current_weapon:
		GameState.WEAPONS.BLAZE:
			weapon_blaze()
		GameState.WEAPONS.SMOG:
			weapon_smog()
		GameState.WEAPONS.SHARK:
			weapon_shark()
		GameState.WEAPONS.ORIGAMI:
			weapon_origami()
		GameState.WEAPONS.GUERRILLA:
			weapon_guerilla()
		GameState.WEAPONS.REAPER:
			weapon_reaper()
		GameState.WEAPONS.CARRY:
			weapon_carry()
		GameState.WEAPONS.ARROW:
			weapon_arrow()
		GameState.WEAPONS.PUNK:
			weapon_punk()
		GameState.WEAPONS.BALLADE:
			weapon_ballade()
		GameState.WEAPONS.QUINT:
			weapon_quint() # Copy Robot only, because I don't wanna mess with Maestro and Sakugarne...
		_:
			return

func weapon_buster(): # G: Maestro can't charge his buster, but Copy Robot *can*.
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3):
			if transing != true:
				shot_type = 0
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 1
				projectile = projectile_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 4
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				Charge = 0
				return

func weapon_blaze():

	if Input.is_action_just_pressed("shoot") and transing != true:
			

		var space : int = 18
		if shield == null && shield2 == null && shield3 == null && shield4 == null && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:

			shot_type = 3
			anim.seek(0)
			attack_timer.start(0.5)
			
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield = weapon_scenes[2].instantiate()
				get_parent().add_child(shield)
				shield.theta = 0*space

			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 3 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield2 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield2)
				shield2.theta = 1*space

			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 2 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield3 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield3)
				shield3.theta = 2*space

			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 4 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield4 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield4)
				shield4.theta = 3*space
				
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.BLAZE] -= 4

		else:
			if shield or shield2 or shield3 or shield4:
				shot_type = 2
				anim.seek(0)
				attack_timer.start(0.3)
				if shield != null:
					shield.fired = true
					if sprite.scale.x == -1:
						shield.left = true
				if shield2 != null:
					shield2.fired = true
					if sprite.scale.x == -1:
						shield2.left = true
				if shield3 != null:
					shield3.fired = true
					if sprite.scale.x == -1:
						shield3.left = true
				if shield4 != null:
					shield4.fired = true
					if sprite.scale.x == -1:
						shield4.left = true

				shield = null
				shield2 = null
				shield3 = null
				shield4 = null

func weapon_smog():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1:
		if transing != true:
			anim.seek(0)
			shot_type = 1
			attack_timer.start(0.3)
			GameState.onscreen_sp_bullets += 1
			projectile = weapon_scenes[1].instantiate()
			get_parent().add_child(projectile)

			projectile.position.x = position.x + sprite.scale.x * 15
			projectile.position.y = position.y + 4
			projectile.velocity.x = sprite.scale.x * 100
			projectile.scale.x = sprite.scale.x
			return

func weapon_shark():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && is_on_floor() && (GameState.weapon_energy[GameState.WEAPONS.SHARK] >= 5 or GameState.infinite_ammo == true):
		if transing != true:
			if GameState.onscreen_sp_bullets < 1:
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 5
				anim.seek(0)
				shot_type = 4
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = weapon_scenes[4].instantiate()
				get_parent().add_child(projectile)
	
				projectile.position.x = position.x + sprite.scale.x * 15
				projectile.position.y = position.y - 3
				projectile.velocity.x = sprite.scale.x * 65
				projectile.scale.x = sprite.scale.x
				return

func weapon_origami():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 4:
		if transing != true:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 1
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			GameState.onscreen_sp_bullets += 3
			projectile = weapon_scenes[0].instantiate()
	
			#SHOOT FORWARD
			if !Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down"):
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y = -ORIGAMI_SPEED * 0.225
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  ORIGAMI_SPEED * 0.225
	
			if Input.is_action_pressed("move_up"):
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.5
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.225
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED *  0.225
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.775
	
			if Input.is_action_pressed("move_down"):
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED *  0.225
				projectile.velocity.y =  ORIGAMI_SPEED * 0.775
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
				projectile.velocity.y =  ORIGAMI_SPEED * 0.5
	
				projectile = weapon_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  ORIGAMI_SPEED * 0.225

			return

func weapon_guerilla():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.GUERRILLA] >= 2 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets <= 2:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.GUERRILLA] -= 2
		anim.seek(0)
		shot_type = 1
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = weapon_scenes[3].instantiate()

		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y + 4
		projectile.velocity.x = sprite.scale.x * 20
		projectile.velocity.y = 10
		projectile.scale.x = sprite.scale.x

func weapon_reaper():
	if Input.is_action_just_released("shoot"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 2 and (GameState.weapon_energy[GameState.WEAPONS.REAPER] > 0 or GameState.infinite_ammo == true):
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			if ScytheCharge < 25: #Uncharged. Throws 1 boomerang with an alternating curve

				projectile = weapon_scenes[5].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 15)
				projectile.position.y = position.y - 2
				projectile.velocity.x = sprite.scale.x * 170
				projectile.scale.x = -sprite.scale.x
				GameState.onscreen_sp_bullets += 1


				if Input.is_action_pressed("move_up"):
					projectile.direction = 1
				elif Input.is_action_pressed("move_down"):
					projectile.direction = -1
				else:
					if  GameState.onscreen_sp_bullets != 1:
						projectile.direction = -1
					else:
						projectile.direction = 1

				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 1

			if ScytheCharge >= 25 and ScytheCharge < 75:  #Mid charge. Throws 2 shots that curve back in opposite ways
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 2
				GameState.onscreen_sp_bullets += 2

				projectile = weapon_scenes[5].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y - 8
				projectile.velocity.x = sprite.scale.x * 210
				projectile.velocity.y = 35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = -1

				projectile = weapon_scenes[5].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y + 8
				projectile.velocity.x = sprite.scale.x * 210
				projectile.velocity.y = -35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = 1

			if ScytheCharge >= 75: #Full charge. Throws 2 shots that run to the top and bottom of the screen and return.
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 4
				GameState.onscreen_sp_bullets += 2

				projectile = weapon_scenes[6].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y + 8
				projectile.velocity.x = sprite.scale.x * 310
				projectile.velocity.y = 35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = -1

				projectile = weapon_scenes[6].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y - 8
				projectile.velocity.x = sprite.scale.x * 310
				projectile.velocity.y = -35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = 1

			ScytheCharge = 0

	if !Input.is_action_pressed("shoot"):
		ScytheCharge = 0

	if ScytheCharge >= 25 && GameState.weapon_energy[GameState.WEAPONS.REAPER] < 2:
		ScytheCharge = 2

	if ScytheCharge >= 75 && GameState.weapon_energy[GameState.WEAPONS.REAPER] < 4:
		ScytheCharge = 26

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.REAPER] > 0 or GameState.infinite_ammo == true):
		if ScytheCharge < 78:
			ScytheCharge += 1
			if ScytheCharge == 13:
				SoundManager.play("player", "charge1")
			if ScytheCharge == 76:
				SoundManager.play("player", "charge2")
		else:
			ScytheCharge = 77
	else:
		Charge = 0
		SoundManager.instance_poly("player", "charge1").release()
		SoundManager.instance_poly("player", "charge2").release()
		return

func weapon_carry():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.CARRY] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 3:
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[3].instantiate()

		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		if is_on_floor():
			projectile.position.y = position.y
			projectile.position.x = position.x + sprite.scale.x * 30
		else:
			projectile.position.y = position.y + 24
			projectile.position.x = position.x

func weapon_arrow():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.ARROW] >= 4 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.ARROW] -= 4
		anim.seek(0)
		shot_type = 1
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[6].instantiate()

		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y + 4
		projectile.velocity.x = sprite.scale.x * 0.001
		projectile.scale.x = sprite.scale.x

func weapon_punk():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.PUNK] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 4:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.PUNK] -= 1
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[5].instantiate()
		projectile.scale.x = sprite.scale.x

		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y

		projectile.velocity.y = -450
		projectile.velocity.x = sprite.scale.x * 95
	return

func weapon_ballade():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.BALLADE] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.BALLADE] -= 3
		anim.seek(0)

		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[4].instantiate()

		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y

		projectile.velocity.y = 0
		projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 1

		if(Input.is_action_pressed("move_up")):
			projectile.velocity.y = -CRACKER_SPEED * 0.5
			projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 0.5

		if(Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
			projectile.velocity.y = -CRACKER_SPEED * 1
			projectile.velocity.x = 0

		if(Input.is_action_pressed("move_down")):
			projectile.velocity.y = CRACKER_SPEED * 0.5
			projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 0.5
			return

func weapon_quint():
	return
#endregion

func _DamageAndInvincible():

	if !invul_timer.is_stopped():
		InvincFrames += 1
		if InvincFrames >= 2:
			sprite.visible = false
		if InvincFrames == 3:
			InvincFrames = 0
			sprite.visible = true
	else:
		sprite.visible = true

	if DmgQueue > 0:
		if !invul_timer.is_stopped():
			DmgQueue = 0
		else:
			if GameState.current_hp - DmgQueue > 0:
				GameState.current_hp -= DmgQueue
			else:
				GameState.current_hp = 0
			DmgQueue = 0
			swapState = STATES.HURT
			if GameState.current_hp <= 0:
				swapState = STATES.DEAD
			invul_timer.start(1)
			pain_timer.start(0.55)

func reset(everything: bool) -> void:
	GameState.refill_health()
	GameState.current_weapon = GameState.WEAPONS.BUSTER # Reset current weapon
	if everything == true:
		GameState.refill_ammo()

func teleport() -> void:
	$MainHitbox.set_disabled(true)
	position.y = move_toward(position.y, targetpos, 10)
	#exit teleport
	if position.y >= targetpos:
		if anim.get_current_animation() == "Teleport":
			SoundManager.play("player", "warp") # G: Sweet, sweet bliss. One teleport sound, as God intended. (I hate this.)
		if anim.get_current_animation() != "Teleport In":
			anim.play("Teleport In")
			velocity.y = 0
			$MainHitbox.set_disabled(false)
			await anim.animation_finished
			swapState = STATES.IDLE
			teleported.emit()

func set_current_weapon_palette() -> void:
	sprite.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])
