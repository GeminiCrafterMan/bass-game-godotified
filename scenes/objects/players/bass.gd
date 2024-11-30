extends MaestroPlayer

class_name BassPlayer

# References
@onready var rapid_timer = $RapidTimer


const ORIGAMI_SPEEDB := 450

# Variables
var buster_speed = 300
var blast_jumped = false
var dashing = false
var dashdir = 0
func _init() -> void:
	weapon_palette = [
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/bass/palettes/Freeze Frame.png"),
		preload("res://sprites/players/bass/palettes/Poison Cloud.png"),
		preload("res://sprites/players/bass/palettes/Fin Shredder.png"),
		preload("res://sprites/players/bass/palettes/Origami Star.png"),
		preload("res://sprites/players/bass/palettes/Wild Gale.png"),
		preload("res://sprites/players/bass/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/bass/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/bass/palettes/Proto Buster.png"),
		preload("res://sprites/players/bass/palettes/Treble.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 1.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png")
	]
	
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/bass/buster.tscn"),
		preload("res://scenes/objects/players/weapons/bass/blast_jump.tscn"),
		preload("res://scenes/objects/players/weapons/bass/track_2.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/weapons/bass/protoshot1.tscn"),
		preload("res://scenes/objects/players/weapons/bass/protoshot2.tscn")
	]

	weapon_scenes = [
		preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/wild_gale.tscn")
	]
	

func _ready() -> void:
	super._ready()
	attack_timer = $FireDelay

# ===============
# STATE FUNCTIONS
# ===============
## Idle state
func state_idle(_direction: Vector2, _delta: float) -> void:
	dashing = false
	blast_jumped = false # Extra safeguard
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
				if Input.is_action_pressed("move_up"):
					if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
						anim.play("Idle-Shoot Steady Diagonal")
					else:
						anim.play("Idle-Shoot Steady Up")
				elif Input.is_action_pressed("move_down"):
					anim.play("Idle-Shoot Steady Down")
				else:
					anim.play("Idle-Shoot Steady")
			2: # Throw
				anim.play("Idle-Throw")
			3: # Shield
				anim.play("Idle-Shield")
			4: # Fin Shredder
				anim.play("FinShredder")
			_: # Everything else
				anim.play("Idle-Shoot")
	if Input.is_action_just_pressed("dash"):
		swapState = STATES.SLIDE

	#movement of this state
	default_movement(_direction, _delta)
	#if inputted, then change state
	if sign(_direction.x) != 0:
		swapState = STATES.WALK

## Walk state
func state_walk(_direction: Vector2, _delta: float) -> void:
	blast_jumped = false # Extra safeguard
	#there is no step state anymore, the walk just kinda winds-up now
	#the code to do this is silly but not dirty :3 -lynn
	if Input.is_action_just_pressed("dash"):
		swapState = STATES.SLIDE

	var progress = anim.get_current_animation_position()

	if !attack_timer.is_stopped():
		match shot_type:
			0: # Normal
				anim.play("Walk-Shoot")
				anim.seek(progress)
			1: # Stop
				if Input.is_action_pressed("move_up"):
					if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
						anim.play("Idle-Shoot Steady Diagonal")
					else:
						anim.play("Idle-Shoot Steady Up")
				elif Input.is_action_pressed("move_down"):
					anim.play("Idle-Shoot Steady Down")
				else:
					anim.play("Idle-Shoot Steady")
			2: # Throw
				anim.play("Idle-Throw")
			3: # Shield
				anim.play("Idle-Shield")
			4: # Shredder
				anim.play("FinShredder")
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

## Slide state -- but here, it's actually a dash!
func state_slide(_direction: Vector2, _delta: float) -> void:
	if isFirstFrameOfState:
		dashing = true
		if velocity.x > 0:
			dashdir = 1
		if velocity.x < 0:
			dashdir = -1
		slide_timer.start()
		SoundManager.play("player", "slide") #	 G: I know, I know, but it's the same sound.
		if GameState.modules_enabled[GameState.WEAPONS.SMOG] == true:
			module_smog()
		else:
			if anim.get_current_animation() != "Dash":
				anim.stop()
				anim.play("Dash")
		#Spawns Smoke
		FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
		get_parent().add_child(FX)
		if sprite.scale.x == -1:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8

	if slide_timer.is_stopped() or Input.is_action_just_released("dash"):
		if $CeilingCheck.is_colliding() == false:
			#Changes to normal state. Rest is handled normally
			swapState = STATES.IDLE
			slide_timer.stop()

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
	if Input.is_action_pressed("move_up") and Input.is_action_just_pressed("jump") and GameState.modules_enabled[GameState.WEAPONS.BLAZE] and blast_jumped == false and isFirstFrameOfState == false:
		module_blaze()
		anim.stop()
		StepTime = 0
		anim.play("Jump")
	#setup needed on first frame of new state
	if isFirstFrameOfState:
		velocity.y = JUMP_VELOCITY
	#if coming in from the shoot animation, set immediatley to falling animation
	if anim.get_current_animation() == "Jump-Shoot":
		anim.stop()
		anim.play("Fall")
	#set animation based on falling for rising
	if velocity.y < 0 and JumpHeight != 80:
		if (JumpHeight < JUMP_HEIGHT and Input.is_action_pressed("jump")):
			velocity.y = JUMP_VELOCITY
			JumpHeight += 1
		if (JumpHeight == JUMP_HEIGHT or (dashing == true and JumpHeight == JUMP_HEIGHT - 10 and in_water== true)):
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
			1: # Stop
				if Input.is_action_pressed("move_up"):
					if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
						anim.play("Jump-Shoot Diagonal")
					else:
						anim.play("Jump-Shoot Up")
				elif Input.is_action_pressed("move_down"):
					anim.play("Jump-Shoot Down")
				else:
					anim.play("Jump-Shoot")
			2: # Throw
				anim.play("Jump-Throw")
			3: # Shield
				anim.play("Jump-Shield")
			4: # Shredder
				anim.play("FinShredder")
			_: # Everything else
				anim.play("Jump-Shoot")

	#behavior of state
	#movement in state
	
	if ice_jump == false and dashing == false:
		default_movement(_direction, _delta)
	elif ice_jump == true:
		ice_jump_move(_direction, _delta)
	elif dashing == true:
		dash_jump(_direction, _delta)

	if is_on_floor() and !isFirstFrameOfState:
		SoundManager.play("player", "land")
		blast_jumped = false
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

# ================
# WEAPON FUNCTIONS
# ================
func weapon_buster():
	if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
		if !attack_timer.is_stopped():
			if shot_type == 1:
				no_grounded_movement = true
		else:
			no_grounded_movement = false
		if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
			if Input.is_action_pressed("move_left"):
				sprite.scale.x = -1
			if Input.is_action_pressed("move_right"):
				sprite.scale.x = 1
			
			if rapid_timer.is_stopped() and GameState.onscreen_bullets < 4:
				rapid_timer.start(0.10)
				shot_type = 1
				GameState.onscreen_bullets += 1
				attack_timer.start(0.4)
				projectile = projectile_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + sprite.scale.x * 5
				projectile.position.y = position.y + 5
				projectile.scale.x = sprite.scale.x
				if GameState.onscreen_bullets == 1 or GameState.onscreen_bullets == 3:
					projectile.frames = 1
				# inputs
				if Input.is_action_pressed("move_up"):
					if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
						projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
						projectile.velocity.y = -(buster_speed * 0.5)
					else:
						projectile.velocity.y = -buster_speed
				elif Input.is_action_pressed("move_down"):
					projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
					projectile.velocity.y = (buster_speed * 0.5)
				else:
					projectile.velocity.x = sign(sprite.scale.x) * buster_speed
					
	#		is_dashing = false
			return

func weapon_origami():
	if Input.is_action_just_pressed("shoot") and (GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 2 or GameState.infinite_ammo == true) and GameState.onscreen_sp_bullets < 1:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 2
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  -ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.825
		projectile.velocity.y = -ORIGAMI_SPEEDB * 0.2
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.825
		projectile.velocity.y =  ORIGAMI_SPEEDB * 0.2
		
		
		return

# ================
# MODULE FUNCTIONS
# ================

func module_blaze() -> void:
	SoundManager.play("bass", "blast_jump")
	velocity.y = -FAST_FALL
	slide_timer.stop()
	blast_jumped = true
	projectile = projectile_scenes[1].instantiate()
	get_parent().add_child(projectile)
	projectile.position.x = position.x
	projectile.position.y = position.y
	projectile.velocity.y = 280
	# G: The way the jump, jump transition, and fall animations play bothers me greatly and this doesn't work because of it.
	anim.play("Jump")
	StepTime = 0

func module_smog() -> void:
	if anim.get_current_animation() != "Mist Dash":
		anim.stop()
		anim.play("Mist Dash")
	#Changes Collision
	$MainHitbox.set_disabled(true)
	$SlideHitbox.set_disabled(false)

func dash_jump(direction, delta):
	if direction.x:
		sprite.scale.x = sign(direction.x)
		if direction.x == dashdir:
			velocity.x = sprite.scale.x * 175
		else:
			velocity.x = sprite.scale.x * MAXSPEED * 0.75
	else:
		velocity.x = 0


func play_start_sound() -> void:
	pass#SoundManager.play("bass", "start")
