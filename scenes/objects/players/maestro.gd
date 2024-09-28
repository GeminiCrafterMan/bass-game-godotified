extends CharacterBody2D

class_name MaestroPlayer

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
	LADDER,
	HURT,
	DEAD
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

var JUMP_VELOCITY : int
var PEAK_VELOCITY : int
var STOP_VELOCITY : int
var JUMP_HEIGHT : int
var FAST_FALL : int

#consts
const MAXSPEED = 100.0
const RUNSPEED = 70.0

#Wepon consts
const ORIGAMI_SPEED = 350
const CRACKER_SPEED = 450

#refrences
@onready var ladder_check = $LadderCheck
@onready var top_ladder_check = $TopLadderCheck
@onready var state_timer = $StateTimer
@onready var invul_timer = $InvulTimer
@onready var pain_timer = $PainTimer
@onready var sprite = $AnimatedSprite2D
@onready var starburst = $FX/Starburst
@onready var sweat = $FX/Sweat
@onready var FX
@onready var projectile
@onready var shield
@onready var shield2
@onready var shield3
@onready var shield4



#other vars
var DmgQueue : int # make the game not crash when you touch an enemy
var JumpHeight : int #How long you're holding the jump button to go higher
var StepTime : int #How long you're stepping
var SlideTimer : int
var PainTimer : int
var InvincFrames : int
var Charge : int
var Flash_Timer : int
var no_grounded_movement : bool
var on_ice : bool
var ice_jump : bool


#Attack vars
var shoot_delay = 0
var shot_type = 0

var weapon_palette: Array[Texture2D] = [
	preload("res://sprites/Players/Maestro (base)/Palettes/Maestro Buster.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Scorch Barrier.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Track 2.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Poison Cloud.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Fin Shredder.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Origami Star.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Wild Gale.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Rolling Bomb.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Boomerang Scythe.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Maestro Buster.png"), # Proto Shield
	preload("res://sprites/Players/Maestro (base)/Palettes/Treble.png"), # "Treble Boost" (skip it)
	preload("res://sprites/Players/Maestro (base)/Palettes/Carry.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Super Arrow.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Mirror Buster.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Screw Crusher.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Ballade Cracker.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Sakugarne.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/ChargeX1.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/ChargeX2.png")
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
	preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn")
]

func _ready():
	GameState.player = self.get_path()
	#start the teleport animation
	state_timer.start(0.5)
	invul_timer.start(0.01)
	currentState = STATES.TELEPORT
	sprite.play("Teleport")
	
	JUMP_VELOCITY = -225.0
	PEAK_VELOCITY = -90.0
	STOP_VELOCITY = -80.0
	JUMP_HEIGHT = 13
	FAST_FALL = 400.0
	

func _physics_process(delta: float) -> void:
	if GameState.current_hp > 28 or Input.is_action_just_pressed("debug_health"):
		GameState.current_hp = 28
	if GameState.weapon_energy[GameState.current_weapon] > 28 or Input.is_action_just_pressed("debug_energy"):
		GameState.weapon_energy[GameState.current_weapon] = 28
	
	
	# Add the gravity.
	if (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
		if not is_on_floor():
			velocity += get_gravity() * delta

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
			
				if (GameState.current_weapon == 16):
					GameState.current_weapon = 0
				else:
					GameState.current_weapon += 1
			
					if (GameState.current_weapon != 0):
						while (GameState.weapons_unlocked[GameState.current_weapon] == false):
							if (GameState.current_weapon == 16 && GameState.weapons_unlocked[16] == false):
								GameState.current_weapon = 0
							else:
								GameState.current_weapon += 1
					
						
		if Input.is_action_just_pressed("switch_left"):
			if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
				GameState.old_weapon = GameState.current_weapon
					
				if (GameState.current_weapon == 0):
					GameState.current_weapon = 16
				else:
					GameState.current_weapon -= 1
				
				while (GameState.weapons_unlocked[GameState.current_weapon] == false):
					GameState.current_weapon -= 1
						
		
	if GameState.old_weapon != GameState.current_weapon:
		$Audio/SwitchSound.play()
		GameState.old_weapon = GameState.current_weapon
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

	if  (Input.is_action_just_pressed("switch_left") && Input.is_action_pressed("switch_right")) or (Input.is_action_pressed("switch_left") && Input.is_action_just_pressed("switch_right")):
		if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
			GameState.current_weapon = 0
			if GameState.old_weapon != GameState.current_weapon:
				$Audio/SwitchSound.play()
			$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])
		
	
	
	if ($CeilingCheck.is_colliding() == false or (currentState != STATES.SLIDE) and (currentState != STATES.HURT)):
		_DamageAndInvincible()
	
	if velocity.y > FAST_FALL:
		velocity.y = FAST_FALL
		
	if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && currentState != STATES.TELEPORT:
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
		if  (currentState != STATES.NONE) and (currentState != STATES.TELEPORT) and (currentState != STATES.DEAD):
			#check for ladder
			if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and  sign(direction.y) != 0:
				if ladder_check.is_colliding() and !Input.is_action_pressed("jump"):
					for i in ladder_check.get_collision_count():
						if ladder_check.get_collider(i).is_in_group("ladder"):
							
							if !(is_on_floor() and Input.is_action_pressed("move_down")):
								global_position.x = ladder_check.get_collider(i).global_position.x
								currentState = STATES.LADDER
								print("Ladder'd")
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
				$MainHitbox.set_disabled(true)
				position.y = move_toward(position.y, targetpos, 10)
				#exit teleport
				if position.y >= targetpos:
					if not sprite.animation == "Teleport In":
						sprite.play("Teleport In")
						velocity.y = 0
						$MainHitbox.set_disabled(false)
						$Audio/WarpInSound.play()
						await sprite.animation_finished
						swapState = STATES.IDLE
						teleported.emit()
			
			STATES.IDLE:
				#play animation
				if shoot_delay == 0:
					if StepTime > 0:
						StepTime -= 1
						if sprite.animation != "Step":
							sprite.stop()
							sprite.play("Step")
				
					else:
						if sprite.animation != "Idle":
							sprite.stop()
							sprite.play("Idle")
	
				else:
					match shot_type:
						0: # Normal
							$AnimatedSprite2D.play("Idle-Shoot")
						1: # StopShoot
							$AnimatedSprite2D.play("Idle-Shoot")
						2: # Throw
							$AnimatedSprite2D.play("Idle-Throw")
						3: # Shield
							$AnimatedSprite2D.play("Idle-Shield")
						4: # Fin Shredder
							$AnimatedSprite2D.play("FinShredder")
						_: # Everything else
							$AnimatedSprite2D.play("Idle-Shoot")
						
						
						
						
				if Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump"):
					swapState = STATES.SLIDE
				
				#movement of this state
				default_movement(direction, delta)
				#if inputted, then change state
				if sign(direction.x) != 0:
					swapState = STATES.WALK
			STATES.WALK:
				#there is no step state anymore, the walk just kinda winds-up now
				#the code to do this is silly but not dirty :3 -lynn
				if Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump"):
					swapState = STATES.SLIDE
				
				var progress = sprite.get_frame_progress()
				var frame = sprite.get_frame()
					
				if shoot_delay > 0:
					match shot_type:
						0: # Normal
							$AnimatedSprite2D.play("Walk-Shoot")
						1: # Stop
							$AnimatedSprite2D.play("Idle-Shoot")
						2: # Throw
							$AnimatedSprite2D.play("Idle-Throw")
						3: # Shield
							$AnimatedSprite2D.play("Idle-Shield")
						4: # Shredder
							$AnimatedSprite2D.play("FinShredder")
						_: # Everything else
							$AnimatedSprite2D.play("Walk-Shoot")
				else:
					if StepTime > 6:
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
					FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
					get_parent().add_child(FX)
					if sprite.scale.x == -1:
						FX.scale.x = -1
						FX.position.x = position.x + 15
					else:
						FX.position.x = position.x - 15
					FX.position.y = position.y+8
					
				if SlideTimer > 24:
					
					if $CeilingCheck.is_colliding() == false:
						#Changes to normal state.Rest is handled normally
						swapState = STATES.IDLE
						SlideTimer = 0
						print("idled bad")
				else:
					SlideTimer += 1
									
				if on_ice == false:
					velocity.x = sprite.scale.x * 200
				else:
					velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * 4)
				
				
				if $CeilingCheck.is_colliding() == false:
					if isFirstFrameOfState == false:
						if sign(direction.x) == sign(-sprite.scale.x):
							swapState = STATES.WALK
					
				
				if $CeilingCheck.is_colliding() == true:
					if direction.x:
						sprite.scale.x = sign(direction.x)
					
			STATES.JUMP:
				#setup needed on first frame of new state
				if isFirstFrameOfState:
					velocity.y = JUMP_VELOCITY
				#if coming in from the shoot animation, set immediatley to falling animation
				if sprite.animation == "Jump-Shoot":
					sprite.stop()
					sprite.play("Fall")
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
						if shoot_delay == 0:
							sprite.stop()
							sprite.play("Jump")
						$Audio/JumpSound.play()
					
				else:
					if shoot_delay == 0:
						if StepTime < 7:
							StepTime += 1
							sprite.play("Jump Transition")
						else:
							sprite.play("Fall")
						
				if shoot_delay > 0:
					match shot_type:
						0: # Normal
							$AnimatedSprite2D.play("Jump-Shoot")
						1: # Normal
							$AnimatedSprite2D.play("Jump-Shoot")
						2: # Throw
							$AnimatedSprite2D.play("Jump-Throw")
						3: # Shield
							$AnimatedSprite2D.play("Jump-Shield")
						4: # Shredder
							$AnimatedSprite2D.play("FinShredder")
						_: # Everything else
							$AnimatedSprite2D.play("Jump-Shoot")
							
					#behavior of state
					#movement in state
				if ice_jump == false:
					default_movement(direction, delta)
				else:
					ice_jump_move(direction,delta)
				
				if is_on_floor() and !isFirstFrameOfState:
					$Audio/LandSound.play() #G: ends up playing when you jump, too...?
					swapState = STATES.IDLE
					if on_ice == false:
						ice_jump = false
				
			STATES.LADDER:
				if shoot_delay != 0 or Input.is_action_just_pressed("buster") or Input.is_action_just_pressed("shoot"):
					if direction.x != 0:
						sprite.scale.x = sign(direction.x)
					if sprite.animation != "Ladder-Shoot":
						sprite.stop()
						sprite.play("Ladder-Shoot")
					#pause and play ladder animation
					#turn this into lining the climb and shoot animations up later
					if sprite.is_playing() == true:
						sprite.pause()
				else:
					if sprite.animation != "Ladder":
						sprite.stop()
						sprite.play("Ladder")
					#pause and play ladder animation
					if direction.y != 0:
						if sprite.is_playing() == false:
							sprite.play("Ladder")
					else:
						if sprite.is_playing() == true:
							sprite.pause()
				
				#movement
				velocity.x = 0
				#THIS IS THE SPEED OF THE LADDER
				#remove this if statement to allow moving while shooting on ladders
				if shoot_delay == 0:
					velocity.y = sign(direction.y) * -100
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
			
			STATES.HURT:
				if isFirstFrameOfState:
					if GameState.current_hp <= 0:
						swapState = STATES.DEAD
					starburst.visible = true
					sweat.play("active")
					sweat.set_frame_and_progress(0, 0)
					
					
					if GameState.current_hp > 0:
						$Audio/HurtSound.play()
					if sprite.animation != "Hurt":
							sprite.stop()
							sprite.play("Hurt")
				if pain_timer.is_stopped():
					swapState = STATES.IDLE
					starburst.visible = false
				else:
					velocity.x = sprite.scale.x * 20
					
				if isFirstFrameOfState == true:
					if is_on_floor():
						velocity.y = -70
					else:
						velocity.y = -90
					
			STATES.DEAD:
				if isFirstFrameOfState:
					
					$MainHitbox.set_disabled(true)
					$SlideHitbox.set_disabled(true)
					state_timer.start(5.00)
					sprite.play("Hurt")
					velocity.y = 0
					velocity.x = 0
							
				if pain_timer.is_stopped():
					$Audio/HurtSound.stop()
					$Audio/DeathSound.play()
					
					sprite.stop()
					sprite.play("None")
					sprite.scale.x = 0
					sprite.visible = false
					projectile = preload("res://scenes/objects/explosion_player.tscn").instantiate()
					get_parent().add_child(projectile)
					projectile.position.x = position.x
					projectile.position.y = position.y
					projectile.velocity.x = -200
					
					velocity.x = 0
					velocity.y = 0
					pain_timer.start(2550)
					
				if state_timer.is_stopped():
					sprite.visible = false
					Fade.fade_out()
					#await Fade.fade_out().finished # G: Seems to not work
					GameState.player_lives -= 1
					reset(false)
					get_tree().reload_current_scene()
					#Reset the stage
			
		
		
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
	if (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
		weapon_buster()
		do_charge_palette()
	
	

func default_movement(direction, delta):
	#movement in state
	if direction.x:
		
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
		

func do_charge_palette():
	if Charge == 0 or Charge < 37: # no charge
		$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
	elif Charge >= 37 && Charge < 65: # just started charging
		if Flash_Timer == 2 || Flash_Timer == 3:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[17])
			Flash_Timer += 1
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer += 1
		if Flash_Timer == 3:
			Flash_Timer = 0
	elif Charge >= 65 && Charge < 92:
		if Flash_Timer == 1:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[17])
			Flash_Timer = 0
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer = 1
	elif Charge >= 92:
		if Flash_Timer == 1:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[18])
			Flash_Timer = 0
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer = 1

func handle_weapons():
	if shoot_delay > 0:
		shoot_delay -= 1
		if shot_type > 0:
			no_grounded_movement = true		
	else:
		no_grounded_movement = false
		
	match GameState.current_weapon:
		1:
			weapon_blaze()
		3:
			weapon_smog()
		4:
			weapon_shark()
		5:
			weapon_origami()
		7:
			weapon_guerilla()
		11:
			weapon_carry()
		12:
			weapon_arrow()
		14:
			weapon_punk()
		15:
			weapon_ballade()
		_:
			return


func weapon_buster(): # G: Maestro can't charge his buster, but Copy Robot *can*.
	if (GameState.current_weapon == 0 and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
			shot_type = 0
			shoot_delay = 16
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.velocity.x = sprite.scale.x * 350
			projectile.scale.x = sprite.scale.x
			Charge = 0
			return

func weapon_blaze():

	if Input.is_action_just_pressed("shoot"):
		
		var space : int = 18
		if shield == null && shield2 == null && shield3 == null && shield4 == null && GameState.weapon_energy[1] >= 1:
			
			shot_type = 3
			$AnimatedSprite2D.set_frame_and_progress(0, 0)
			shoot_delay = 26
			
			if GameState.weapon_energy[1] >= 1:
				shield = weapon_scenes[2].instantiate()
				get_parent().add_child(shield)
				shield.theta = 0*space
			
			if GameState.weapon_energy[1] >= 3:
				shield2 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield2)
				shield2.theta = 1*space
			
			if GameState.weapon_energy[1] >= 2:
				shield3 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield3)
				shield3.theta = 2*space
			
			if GameState.weapon_energy[1] >= 4:
				shield4 = weapon_scenes[2].instantiate()
				get_parent().add_child(shield4)
				shield4.theta = 3*space
				
			GameState.weapon_energy[1] -= 4
			
		else:
			if shield or shield2 or shield3 or shield4:
				shot_type = 2
				$AnimatedSprite2D.set_frame_and_progress(0, 0)
				shoot_delay = 16
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
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 16
		projectile = weapon_scenes[1].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x + sprite.scale.x * 15
		projectile.position.y = position.y + 4
		projectile.velocity.x = sprite.scale.x * 100
		projectile.scale.x = sprite.scale.x
		return
		
func weapon_shark():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && is_on_floor() && GameState.weapon_energy[4] >= 5:
		GameState.weapon_energy[4] -= 5
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 16
		projectile = weapon_scenes[4].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x + sprite.scale.x * 15
		projectile.position.y = position.y - 3
		projectile.velocity.x = sprite.scale.x * 65
		projectile.scale.x = sprite.scale.x
		return

func weapon_origami():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[5] >= 1:
		GameState.weapon_energy[5] -= 1
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 16
		projectile = weapon_scenes[0].instantiate()
			
		#SHOOT FORWARD 
		if !Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down"):
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y = -ORIGAMI_SPEED * 0.225
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
	
		if Input.is_action_pressed("move_up"):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x *ORIGAMI_SPEED *  0.225
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.225
			
		if Input.is_action_pressed("move_down"):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED *  0.225
			projectile.velocity.y =  ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = -sprite.scale.x
			projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
		
		return
		
func weapon_guerilla():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[7] >= 2:
		GameState.weapon_energy[7] -= 2
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 16
		projectile = weapon_scenes[3].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.y = position.y
		projectile.position.x = position.x + sprite.scale.x * 27
		projectile.velocity.x = sprite.scale.x * 20
		projectile.velocity.y = 10
		projectile.scale.x = sprite.scale.x

func weapon_carry():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[11] >= 3:
		GameState.weapon_energy[11] -= 3
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 16
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
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[12] >= 4:
		GameState.weapon_energy[12] -= 4
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 16
		projectile = projectile_scenes[6].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.y = position.y
		projectile.position.x = position.x + sprite.scale.x * 27
		projectile.velocity.x = sprite.scale.x * 0.001
		projectile.scale.x = sprite.scale.x


func weapon_punk():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[14] >= 1:
		GameState.weapon_energy[14] -= 1
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 16
		projectile = projectile_scenes[5].instantiate()
		
		if $AnimatedSprite2D.flip_h:
			projectile.scale.x = -1
				
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		projectile.velocity.y = -450
		projectile.velocity.x = sprite.scale.x * 95
	return


func weapon_ballade():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[15] >= 3:
		GameState.weapon_energy[15] -= 3
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		
		shot_type = 2
		shoot_delay = 16
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
	GameState.current_hp = GameState.max_hp # Reset HP
	GameState.current_weapon = 0 # Reset current weapon
	if everything == true:
		for n in GameState.weapon_energy.size():
		# I hate this. So much.
			GameState.weapon_energy[n] = GameState.max_weapon_energy[n] # Reset WE
		
