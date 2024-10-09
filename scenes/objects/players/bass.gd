extends MaestroPlayer

class_name BassPlayer

@onready var rapid_timer = $RapidTimer

var buster_speed = 300

func _init() -> void:
	attack_timer = $FireDelay
	
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
		preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn")
	]

# ===============
# STATE FUNCTIONS
# ===============
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
				anim.play("Idle-Shoot")
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
		slide_timer.start()
		$Audio/DashSound.play()
		if GameState.modules_enabled[GameState.WEAPONS.SMOG] == true:
			if anim.get_current_animation() != "Mist Dash":
				anim.stop()
				anim.play("Mist Dash")
			#Changes Collision
			$MainHitbox.set_disabled(true)
			$SlideHitbox.set_disabled(false)
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
			$Audio/JumpSound.play()
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
				anim.play("FinShredder")
			_: # Everything else
				anim.play("Jump-Shoot")

	#behavior of state
	#movement in state
	if ice_jump == false and slide_timer.is_stopped() == true:
		default_movement(_direction, _delta)
	else:
		ice_jump_move(_direction, _delta)

	if is_on_floor() and !isFirstFrameOfState:
		$Audio/LandSound.play() #G: ends up playing when you jump, too...?
		swapState = STATES.IDLE
		if on_ice == false:
			ice_jump = false

## Ladder state
func state_ladder(_direction: Vector2, _delta: float) -> void:
	if !attack_timer.is_stopped() or Input.is_action_just_pressed("buster") or Input.is_action_just_pressed("shoot"):
		if _direction.x != 0:
			sprite.scale.x = sign(_direction.x)
		if anim.get_current_animation() != "Ladder-Shoot":
			anim.stop()
			anim.play("Ladder-Shoot")
		#pause and play ladder animation
		#turn this into lining the climb and shoot animations up later
		if anim.is_playing() == true:
			anim.pause()
	else:
		if anim.get_current_animation() != "Ladder":
			anim.stop()
			anim.play("Ladder")
		#pause and play ladder animation
		if _direction.y != 0:
			if anim.is_playing() == false:
				anim.play("Ladder")
		else:
			if anim.is_playing() == true:
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
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 1 && GameState.onscreen_sp_bullets < 4:
		GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 1
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 4
		
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
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
		projectile.velocity.y =  -ORIGAMI_SPEED * 0.5

		
		return
