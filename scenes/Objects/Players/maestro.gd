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


#Attack vars
var shoot_delay = 0
var shot_type = 0

var weapon_palette: Array[Texture2D] = [
	preload("res://sprites/Players/Maestro (base)/Palettes/None.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Scorch Barrier.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Track 2.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Poison Cloud.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Fin Shredder.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Origami Star.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Wild Gale.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Rolling Bomb.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/Boomerang Scythe.png"),
	preload("res://sprites/Players/Maestro (base)/Palettes/None.png"), # Proto Shield
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
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/buster_small.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/buster_medium.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/buster_large.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/carry.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/ballade_cracker.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/screw_crusher.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Copy Robot/arrow.tscn")
	
]

var weapon_scenes = [
	preload("res://scenes/Objects/Players/Weapons/Special Weps/origami_star.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Special Weps/poison_cloud.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Special Weps/scorch_barrier.tscn"),
	preload("res://scenes/Objects/Players/Weapons/Special Weps/rolling_bomb.tscn")
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
	# Add the gravity.
	if (currentState != STATES.DEAD) and (currentState != STATES.TELEPORT):
		if not is_on_floor():
			velocity += get_gravity() * delta

	if GameState.current_hp <= 0:
		swapState = STATES.DEAD
	
	if shield != null:
		shield.baseposx = position.x - sprite.scale.x * 1
		shield.baseposy = position.y+4
		
	if shield2 != null:
		shield2.baseposx = position.x - sprite.scale.x * 1
		shield2.baseposy = position.y+4
		
	if shield3 != null:
		shield3.baseposx = position.x - sprite.scale.x * 1
		shield3.baseposy = position.y+4
		
	if shield4 != null:
		shield4.baseposx = position.x - sprite.scale.x * 1
		shield4.baseposy = position.y+4
	
	#moved the shoot and charge funcs to the bottom so they dont have a delay between states
	
	if currentState != STATES.TELEPORT:
		if currentState != STATES.SLIDE && currentState != STATES.HURT && currentState != STATES.DEAD:
			handle_weapons()
		
		if Input.is_action_just_pressed("switch_right"):
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
		GameState.current_weapon = 0
		if GameState.old_weapon != GameState.current_weapon:
			$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])
		
	
	
	if ($CeilingCheck.is_colliding() == false or currentState != STATES.SLIDE):
		_DamageAndInvincible()
	
	if velocity.y > FAST_FALL:
		velocity.y = FAST_FALL
		
	if currentState != STATES.SLIDE && currentState != STATES.TELEPORT:
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
		if (currentState != STATES.NONE) and (currentState != STATES.TELEPORT) and (currentState != STATES.DEAD):
			#check for ladder
			if sign(direction.y) != 0:
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
			if ((Input.is_action_just_pressed("jump") and is_on_floor() and !isFirstFrameOfState) and currentState != STATES.HURT and currentState != STATES.LADDER) and (currentState != STATES.DEAD):
				if ($CeilingCheck.is_colliding() == false or currentState != STATES.SLIDE):
					swapState = STATES.JUMP
					StepTime = 0
					JumpHeight = 0
					
			#set player to jumping state if not on ground
			if !is_on_floor() and currentState != STATES.JUMP and currentState != STATES.HURT and currentState != STATES.LADDER and currentState != STATES.DEAD:
				#we set current state here or else it will acivate first frame which will make the character jump
				StepTime = 0
				currentState = STATES.JUMP
				swapState = STATES.NONE
				isFirstFrameOfState = false
				
		match currentState:
			STATES.TELEPORT:
#				global_position.x = targetpos.x
				$MainHitbox.set_disabled(true)
				global_position.y = lerpf(global_position.y, targetpos, delta * 10)
				
				#exit teleport
				if roundi(global_position.y) >= roundi(targetpos):
					if not sprite.animation == "Teleport In":
						sprite.play("Teleport In")
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
							$AnimatedSprite2D.play("Throw")
						3: # Shield
							$AnimatedSprite2D.play("Cast")
						4: # Double Reppuken
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
							$AnimatedSprite2D.play("Throw")
						3: # Shield
							$AnimatedSprite2D.play("Cast")
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
						SlideTimer = 0
						print("idled bad")
				else:
					SlideTimer += 1
					
				velocity.x = -sprite.scale.x * 200
				
				if $CeilingCheck.is_colliding() == false:
					if isFirstFrameOfState == false:
						if sign(direction.x) == sign(sprite.scale.x):
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
							$AnimatedSprite2D.play("Cast")
						4: # Shredder
							$AnimatedSprite2D.play("FinShredder")
						_: # Everything else
							$AnimatedSprite2D.play("Jump-Shoot")
							
					#behavior of state
					#movement in state
				default_movement(direction, delta)
				
				if is_on_floor() and !isFirstFrameOfState:
					$Audio/LandSound.play() #G: ends up playing when you jump, too...?
					swapState = STATES.IDLE
				
			STATES.LADDER:
				if shoot_delay != 0 or Input.is_action_just_pressed("buster") or Input.is_action_just_pressed("shoot"):
					if direction.x != 0:
						sprite.scale.x = sign(-direction.x)
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
					state_timer.start(0.5)
					sprite.play("Hurt")
					velocity.y = 0
					velocity.x = 0
							
				if pain_timer.is_stopped():
					
					$Audio/DeathSound.play()
					$Audio/HurtSound.stop()
						
					projectile = preload("res://scenes/Objects/explosion_player.tscn").instantiate()
					get_parent().add_child(projectile)
					projectile.position.x = position.x
					projectile.position.y = position.y
					projectile.velocity.x = -200
					
		
					queue_free()
				
		
		
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
	if swapState != STATES.TELEPORT and  swapState != STATES.DEAD:
		weapon_buster()
		do_charge_palette()
	
	

func default_movement(direction, delta):
	#movement in state
	if direction.x:
		
		if is_on_floor() == true && no_grounded_movement == true:
			currentSpeed = 0
		
		else:
			sprite.scale.x = sign(-direction.x)
		
			if StepTime < 6 && currentState != STATES.JUMP:
				if StepTime < 1:
					position.x = position.x + direction.x
				StepTime += 1
		
			else:
				if currentState != STATES.JUMP:
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
	match GameState.current_weapon:
		1:
			weapon_blaze()
		3:
			weapon_smog()
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


func weapon_buster():
	if shoot_delay > 0:
		if shot_type == 0:
			shoot_delay -= 1
			no_grounded_movement = false
	if (GameState.current_weapon == 0 and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if  currentState != STATES.SLIDE:
			shot_type = 0
			shoot_delay = 13
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.velocity.x = -sprite.scale.x * 350
			projectile.scale.x = -sprite.scale.x
			Charge = 0
			return
	if (GameState.current_weapon == 0 and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if currentState != STATES.SLIDE:
			if Charge < 32: # no Charge
				Charge = 0
				return
			if Charge >= 32 and Charge < 92: # medium charge
				shot_type = 0
				shoot_delay = 13
				projectile = projectile_scenes[1].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				projectile.velocity.x = -sprite.scale.x * 450
				projectile.scale.x = -sprite.scale.x
				Charge = 0
				$Audio/Charge1.stop()
				return
			if Charge >= 92: # da big boi
				shot_type = 0
				shoot_delay = 13
				projectile = projectile_scenes[2].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				projectile.velocity.x = -sprite.scale.x * 500
				projectile.scale.x = -sprite.scale.x
				Charge = 0
				return
	if (GameState.current_weapon == 0 and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
		if Charge < 110:
			Charge += 1
			if Charge == 32:
				$Audio/Charge1.play()
			if Charge == 105:
				$Audio/Charge2.play()
		else:
			Charge = 105
#			$Audio/Charge2.stop()
				
			
	else:
		Charge = 0
		return

func weapon_blaze():
	if shoot_delay > 0:
		if shot_type == 2 or shot_type == 3:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false

	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		
		var space : int = 17
		if shield == null && shield2 == null && shield3 == null && shield4 == null:
			shot_type = 3
			shoot_delay = 26
			shield = weapon_scenes[2].instantiate()
			get_parent().add_child(shield)
			shield.theta = 0*space
			
			shield2 = weapon_scenes[2].instantiate()
			get_parent().add_child(shield2)
			shield2.theta = 1*space
			
			shield3 = weapon_scenes[2].instantiate()
			get_parent().add_child(shield3)
			shield3.theta = 2*space
			
			shield4 = weapon_scenes[2].instantiate()
			get_parent().add_child(shield4)
			shield4.theta = 3*space
		else:
			shot_type = 2
			shoot_delay = 13
			if shield != null:
				shield.fired = true
				if sprite.scale.x == 1:
					shield.left = true
			if shield2 != null:
				shield2.fired = true
				if sprite.scale.x == 1:
					shield2.left = true
			if shield3 != null:
				shield3.fired = true
				if sprite.scale.x == 1:
					shield3.left = true
			if shield4 != null:
				shield4.fired = true
				if sprite.scale.x == 1:
					shield4.left = true
				
			shield = null
			shield2 = null
			shield3 = null
			shield4 = null

func weapon_smog():
	if shoot_delay > 0:
		if shot_type == 1:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false

	if Input.is_action_just_pressed("shoot") && currentState != STATES.SLIDE:
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 13
		projectile = weapon_scenes[1].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x -sprite.scale.x * 15
		projectile.position.y = position.y + 4
		projectile.velocity.x = -sprite.scale.x * 100
		projectile.scale.x = -sprite.scale.x
		
		# inputs
		
		return

func weapon_origami():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 13
		projectile = weapon_scenes[0].instantiate()
			
		#SHOOT FORWARD 
		if !Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down"):
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y = -ORIGAMI_SPEED * 0.225
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
	
		if Input.is_action_pressed("move_up"):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x *ORIGAMI_SPEED *  0.225
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.225
			
		if Input.is_action_pressed("move_down"):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED *  0.225
			projectile.velocity.y =  ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = -sprite.scale.x * ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
		
		return
		
func weapon_guerilla():
	if shoot_delay > 0:
		if shot_type == 1:
			shoot_delay -= 1
			no_grounded_movement = false
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 13
		projectile = weapon_scenes[3].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.y = position.y
		projectile.position.x = position.x - sprite.scale.x * 27
		projectile.velocity.x = -sprite.scale.x * 20
		projectile.velocity.y = 10
		projectile.scale.x = -sprite.scale.x

func weapon_carry():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 13
		projectile = projectile_scenes[3].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		if is_on_floor():	
			projectile.position.y = position.y
			projectile.position.x = position.x  - sprite.scale.x * 30
		else:
			projectile.position.y = position.y + 24
			projectile.position.x = position.x

func weapon_arrow():
	if shoot_delay > 0:
		if shot_type == 1:
			shoot_delay -= 1
			no_grounded_movement = false
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 13
		projectile = projectile_scenes[6].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.y = position.y
		projectile.position.x = position.x - sprite.scale.x * 27
		projectile.velocity.x = -sprite.scale.x * 0.001
		projectile.scale.x = -sprite.scale.x


func weapon_punk():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
		no_grounded_movement = true
	else:
		no_grounded_movement = false
		
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 13
		projectile = projectile_scenes[5].instantiate()
		
		if $AnimatedSprite2D.flip_h:
			projectile.scale.x = -1
				
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		projectile.velocity.y = -450
		projectile.velocity.x = -sprite.scale.x * 95
	return


func weapon_ballade():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
		no_grounded_movement = true
	else:
		no_grounded_movement = false
		
	if Input.is_action_just_pressed("shoot"):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		
		shot_type = 2
		shoot_delay = 13
		projectile = projectile_scenes[4].instantiate()
		
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		projectile.velocity.y = 0
		projectile.velocity.x = -sprite.scale.x * CRACKER_SPEED * 1
			
		if(Input.is_action_pressed("move_up")):
			projectile.velocity.y = -CRACKER_SPEED * 0.5
			projectile.velocity.x = -sprite.scale.x * CRACKER_SPEED * 0.5
			
		if(Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
			projectile.velocity.y = -CRACKER_SPEED * 1
			projectile.velocity.x = 0
						
		if(Input.is_action_pressed("move_down")):
			projectile.velocity.y = CRACKER_SPEED * 0.5
			projectile.velocity.x = -sprite.scale.x * CRACKER_SPEED * 0.5
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
