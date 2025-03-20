extends MaestroPlayer

class_name CopyRobotPlayer

# Variables
var sharkcharge : int
var pogo : bool = false

func _init() -> void:
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/carry.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/arrow.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/cr_fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/sakugarne.tscn")
	]

	weapon_palette = [
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/copy_robot/palettes/Track 2.png"),
		preload("res://sprites/players/copy_robot/palettes/Poison Cloud.png"),
		preload("res://sprites/players/copy_robot/palettes/Fin Shredder.png"),
		preload("res://sprites/players/copy_robot/palettes/Origami Star.png"),
		preload("res://sprites/players/copy_robot/palettes/Wild Gale.png"),
		preload("res://sprites/players/copy_robot/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/copy_robot/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/players/copy_robot/palettes/Carry.png"),
		preload("res://sprites/players/copy_robot/palettes/Super Arrow.png"),
		preload("res://sprites/players/copy_robot/palettes/Mirror Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Screw Crusher.png"),
		preload("res://sprites/players/copy_robot/palettes/Ballade Cracker.png"),
		preload("res://sprites/players/copy_robot/palettes/Sakugarne.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX1.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge0.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge1.png")
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



#So basically what this new state machine does is that it organizes every state into a little chunk that'll execute the functions it's meant to each frame. This way you won't need to have the
#function that applies gravity need to specify to only apply it during certain states since it will only execute on the correct states. It's also just nicer to look at.

func _physics_process(delta: float) -> void:
	if GameState.current_hp <= 0:
		currentState = STATES.DEAD
	
	GameState.player.position.x = position.x
	GameState.player.position.y = position.y
	GameState.playerstate = currentState
	if GameState.onscreen_sp_bullets < 0:
		GameState.onscreen_sp_bullets = 0
	if GameState.onscreen_bullets < 0:
		GameState.onscreen_bullets = 0
	if GameState.current_hp > 28:
		GameState.current_hp = 28
	if GameState.weapon_energy[GameState.current_weapon] > GameState.max_weapon_energy[GameState.current_weapon]:
		GameState.weapon_energy[GameState.current_weapon] = GameState.max_weapon_energy[GameState.current_weapon]
	#INPUTS -lynn
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	#this cancels out any floats in the inputs and makes inputs to be purely digital (-1,0,1) rather than analouge
	direction = Vector2(sign(direction.x), sign(direction.y))
	$states.text = "[center]%s[/center]" % STATES.keys()[currentState]
	if transing != true:
		match currentState:
			STATES.TELEPORT, STATES.TELEPORT_LANDING:
				teleporting()
				applyGrav(delta)
			STATES.IDLE, STATES.IDLE_SHOOT:
				idle(delta)
				slideProcess()
				checkForFloor()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.IDLE_THROW:
				checkForFloor()
				processJump()
				processShoot()
				processDamage()
			STATES.IDLE_SHIELD:
				checkForFloor()
				processShoot()
				processDamage()
				
			STATES.STEP:
				step(delta)
				checkForFloor()
				slideProcess()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.WALK, STATES.WALKING_SHOOT:
				walk()
				slideProcess()
				checkForFloor()
				processJump()
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.FALL_START, STATES.FALL, STATES.FALL_SHOOT, STATES.FALL_THROW, STATES.FALL_SHIELD:
				fall(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.SLIDE:
				sliding(delta)
				if !$ceilCheck.is_colliding():
					processJump()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.LADDER:
				ladder()
				processCharge()
				processShoot()
				processBuster()
				processDamage()
			STATES.HURT:
				hurt()
				applyGrav(delta)
			STATES.DEAD:
				dead()
		position.x += wind_push
		animationMatching()
		switchWeapons()
		move_and_slide()
		
	
#region Character Things

func invul(arg):
	hurtbox.monitorable = arg

func applyGrav(delta):
	if transing != true:
		if not is_on_floor():
			velocity += get_gravity() * delta
			if fallstored != 0:
				velocity.y = fallstored
				fallstored = 0
			if FAST_FALL < velocity.y:
				velocity.y = FAST_FALL
	else:
		if velocity.y != 0:
			fallstored = velocity.y
			velocity.y = 0

func teleporting():
	if is_on_floor() && currentState == STATES.TELEPORT:
		position.y += 5
		teleported.emit()
		currentState = STATES.TELEPORT_LANDING

func idle(delta):
	if direction.x != 0:
		if on_ice == false:
			position.x += direction.x
			velocity.x = 0
		StepTime = 0
		currentState = STATES.STEP
	if on_ice == true:
		velocity.x = lerpf(velocity.x, 0, delta * ICE_FLOOR_WEIGHT)
	else:
		velocity.x = 0

func step(delta):
	StepTime += 1
	if direction.x == 0:
		currentState = STATES.IDLE
	else:
		sprite.scale.x = direction.x
	if StepTime > 4:
		currentState = STATES.WALK

func walk():
	if direction.x == 0:
		currentState = STATES.IDLE

func allowLeftRight(delta):
	if direction.x != 0:
		sprite.scale.x = direction.x
		if on_ice == true:
			if (sprite.scale.x != sign(direction.x)) and currentSpeed != 0:
				if is_on_floor() == true && on_ice == true:
					if velocity.x <= -MAXSPEED && velocity.x >= MAXSPEED:
						velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * ICE_FLOOR_WEIGHT)
				else:
					currentSpeed = MAXSPEED
			if is_on_floor() == true && on_ice == true:
				velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.25, delta * ICE_FLOOR_WEIGHT)
		elif is_on_floor() == false && ice_jump == true:
				velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.25, delta * ICE_AIR_WEIGHT)
		elif slowed == true:
			pass
			
		else:
			velocity.x = MAXSPEED * direction.x
			sprite.scale.x = direction.x
			#velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * 4)
			
	#else:
		#if on_ice == false:
			#velocity.x = 0
		#else:
			#velocity.x = lerpf(velocity.x, 0, delta * 2 * sprite.scale.x)

func checkForFloor():
	if !is_on_floor():
		currentState = STATES.FALL_START

func processJump():
	if Input.is_action_just_pressed("jump") && direction.y != -1:
		velocity.y = JUMP_VELOCITY
		currentState = STATES.JUMP
		slide_timer.stop()
		$hurtboxArea/mainHurtbox.set_disabled(false)
		$mainCollision.disabled = false
		JumpHeight = 0
		SoundManager.play("player", "jump")

func processDamage():
	#Process the Invul Frames first!
	if !invul_timer.is_stopped():
		invincible = true
		$hurtboxArea/mainHurtbox.set_disabled(true)
		$hurtboxArea/slideHurtbox.set_disabled(true)
		DmgQueue = 0
		InvincFrames += 1
		if InvincFrames >= 2:
			sprite.visible = false
		if InvincFrames == 3:
			InvincFrames = 0
			sprite.visible = true
	else:
		if invincible == true:
			$FX/Starburst.visible = false
			if currentState == STATES.SLIDE:
				$hurtboxArea/slideHurtbox.set_disabled(false)
			else:
				$hurtboxArea/mainHurtbox.set_disabled(false)
			invincible = false
			
		sprite.visible = true
		
	#If you're not invulnerable... eat shit!
	if DmgQueue > 0:
		$FX/Starburst.visible = true
		$FX/Sweat.visible = true
		$FX/Sweat.play("active")
		invul_timer.start(1.0)
		pain_timer.start(0.55)
		GameState.current_hp -= DmgQueue
		if GameState.current_hp >= 0:
			currentState = STATES.HURT
			velocity.x = sprite.scale.x * -20
			if is_on_floor():
				velocity.y = -70
			else:
				velocity.y = -90
		DmgQueue = 0
		SoundManager.play("player", "hurt")

func Jump(delta):
	if on_ice == true:
		ice_jump = true
	if velocity.y < 0 && JumpHeight != 80:
		if (JumpHeight < JUMP_HEIGHT && Input.is_action_pressed("jump")):
			velocity.y = JUMP_VELOCITY
			JumpHeight += 1
		if (JumpHeight == JUMP_HEIGHT):
			JumpHeight = 80
			velocity.y = PEAK_VELOCITY
			currentState = STATES.FALL_START
		if (Input.is_action_just_released("jump")):
			JumpHeight = 80
			velocity.y = STOP_VELOCITY
			currentState = STATES.FALL_START
	if direction.x == 0 :
		if ice_jump == false:
			velocity.x = 0
		else:
			velocity.x = lerpf(velocity.x, 0, delta * ICE_AIR_WEIGHT)
	if is_on_ceiling():
		JumpHeight = 80
		velocity.y = STOP_VELOCITY
		currentState = STATES.FALL_START
	if is_on_floor():
		ice_jump = false
		if direction.x != 0:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE

func fall(delta):
	if direction.x == 0 :
		if ice_jump == false:
			velocity.x = 0
		else:
			velocity.x = lerpf(velocity.x, 0, delta * ICE_AIR_WEIGHT)
	if is_on_floor():
		ice_jump = false
		if direction.x != 0:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
	if currentState == STATES.FALL_START:
		fall_timer += 1
		if fall_timer > 10:
			currentState = STATES.FALL
	else:
		fall_timer = 0

func ladderCheck():
	if !Input.is_action_pressed("jump"):
		if direction.y == 1 && $upLadder.is_colliding():
			ladderArea = $upLadder.get_collider()
			ladderArea.refreshCollis(true)
			currentState = STATES.LADDER
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x
		if direction.y == -1 && $downLadder.is_colliding():
			ladderArea = $downLadder.get_collider()
			ladderArea.refreshCollis(false)
			currentState = STATES.LADDER
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x

func ladder():
	if direction.y != 0:
		velocity.y = -MAXSPEED*direction.y
	else:
		velocity.y = 0
	if direction.y == 1 && $upLadder.is_colliding() == false:
		currentState = STATES.IDLE
		velocity.y = 0
	if direction.y == -1 && is_on_floor():
		velocity.y = 0
		currentState = STATES.IDLE
	if Input.is_action_just_pressed("jump") && is_on_floor() == false:
		velocity.y = 0
		currentState = STATES.FALL


func _on_collision_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("touching ladder!")

func _on_collision_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("not touching ladder...")

func slideProcess():
	if direction.y == -1 && Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
		if on_ice != true:
			velocity.x = 200 * sprite.scale.x
		currentState = STATES.SLIDE
		$mainCollision.disabled = true
		$hurtboxArea/mainHurtbox.set_disabled(true)
		slide_timer.start(0.4)
		FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
		get_parent().add_child(FX)
		if sprite.scale.x == -1:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8
		SoundManager.play("player", "slide")

func sliding(delta):
	if on_ice == false:
		velocity.x = 200 * sprite.scale.x
	else:
		velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * 4)
	
	if direction.x != 0:
		if direction.x + sprite.scale.x == 0:
			if $ceilCheck.is_colliding():
				sprite.scale.x = direction.x
			else:
				slide_timer.start(0.001)
	
	if !is_on_floor():
		velocity.x = 0
		currentState = STATES.FALL
	if Input.is_action_just_pressed("jump"):
		$mainCollision.disabled = true
		$hurtboxArea/mainHurtbox.set_disabled(true)
		
func _on_slide_timer_timeout() -> void:
	if $ceilCheck.is_colliding():
		print("keep sliding")
		slide_timer.start(0.1)
	else:
		$mainCollision.disabled = false
		$hurtboxArea/mainHurtbox.set_disabled(false)
		if !is_on_floor():
			pass
		if on_ice == false:
			velocity.x = 0
		if direction.x:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
		


func _on_water_check(area: Area2D) -> void:
	if area.is_in_group("splash"):
		var splash = preload("res://scenes/objects/splash.tscn").instantiate()
		add_child(splash)
		splash.name = "splashie"
		splash.top_level = true
		splash.global_position = $waterCheck.global_position



func hurt():
	if pain_timer.is_stopped():
		invul(false)
		if is_on_floor():
			currentState = STATES.IDLE
		else:
			currentState = STATES.FALL

func death():
	if pain_timer.is_stopped():
		SoundManager.play("player", "death")

func dead():
	$hurtboxArea/mainHurtbox.set_disabled(true)
	$hurtboxArea/slideHurtbox.set_disabled(true)
	state_timer.start(5.00)
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

#endregion


# ================
# WEAPON FUNCTIONS
# ================
func weapon_buster(): # G: Copy Robot *can* charge his buster, but Maestro and Bass *can't*. Looks like we could easily do the same (replacing the Buster) with Bass's...?
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3):
			shot_type = 0
			attack_timer.start(0.3)
			GameState.onscreen_bullets += 1
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x + (sprite.scale.x * 18)
			projectile.position.y = position.y + 2
			projectile.velocity.x = sprite.scale.x * 350
			projectile.scale.x = sprite.scale.x
			Charge = 0
			return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3):
			if Charge < 32: # no Charge
				Charge = 0
				return
			if Charge >= 32 and Charge < 92: # medium charge
				shot_type = 0
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 1
				projectile = projectile_scenes[1].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 2
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				Charge = 0
				SoundManager.instance_poly("player", "charge1").release()
				SoundManager.instance_poly("player", "charge2").release()
				return
			if Charge >= 92: # da big boi
				shot_type = 0
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 3
				projectile = projectile_scenes[2].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 2
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				Charge = 0
				SoundManager.instance_poly("player", "charge1").release()
				SoundManager.instance_poly("player", "charge2").release()
				return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
		if Charge < 111:
			Charge += 1
			if Charge == 32:
				SoundManager.play("player", "charge1")
			if Charge == 105:
				SoundManager.play("player", "charge2")
			
		else:
			Charge = 103
	else:
		Charge = 0
		return
		
func weapon_shark():
	if Input.is_action_just_released("shoot"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 3 or GameState.infinite_ammo == true):
			if sharkcharge < 25: #Uncharged. Single Fin Shredder

				anim.seek(0)
				shot_type = 4
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = weapon_scenes[4].instantiate()
				get_parent().add_child(projectile)
				
				
				
				if !is_on_floor():
					projectile.position.x = position.x + sprite.scale.x * 25
				else:
					projectile.position.x = position.x + sprite.scale.x * 15
				
				projectile.position.y = position.y - 3
				
				if !is_on_floor():
					projectile.velocity.x = sprite.scale.x * 45
				else:
					projectile.velocity.x = sprite.scale.x * 1
				projectile.scale.x = sprite.scale.x
				
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 3

			if sharkcharge > 25: #Charged. Double Fin Shredder!
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 4
				GameState.onscreen_sp_bullets += 1

				anim.seek(0)
				shot_type = 5
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = projectile_scenes[7].instantiate()
				get_parent().add_child(projectile)

				projectile.position.x = position.x + sprite.scale.x * 35
				projectile.position.y = position.y + 2
				
				projectile.velocity.x = sprite.scale.x * 0.1
				projectile.scale.x = sprite.scale.x

			sharkcharge = 0

	if !Input.is_action_pressed("shoot"):
		sharkcharge = 0

	if sharkcharge >= 25 && GameState.weapon_energy[GameState.WEAPONS.SHARK] < 6:
		sharkcharge = 2

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 0 or GameState.infinite_ammo == true):
		if sharkcharge < 78:
			sharkcharge += 1
			if sharkcharge == 26:
				SoundManager.play("player", "charge1")
		else:
			sharkcharge = 77
	else:
		Charge = 0
		SoundManager.instance_poly("player", "charge1").release()
		SoundManager.instance_poly("player", "charge2").release()
		return
		
func weapon_quint():
	if Input.is_action_just_pressed("shoot") and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.QUINT] > 1 or GameState.infinite_ammo == true):
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[8].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y - 40
		projectile.scale.x = sprite.scale.x
		return
	return
	
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
			
	if sharkcharge > 0: #Fin Shredder!
		Charge = 0
	
	if sharkcharge == 1: #Do NOT touch.
		SoundManager.play("player", "fincharge1")
		
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		sharkcharge = 0
	if sharkcharge > 0 and sharkcharge < 35: # no charge
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[21])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer += 1


	elif sharkcharge >= 35: #Double Fin Shredder!
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[22])
			Flash_Timer = 0
		else:
			set_current_weapon_palette()
			Flash_Timer += 1

func mount_sakugarne() -> void:
	SoundManager.play("copy_robot", "start") # why replace the teleport stuff for a single extra sound?
	pogo = true
	$SakugarneArea.process_mode = Node.PROCESS_MODE_INHERIT
	$SakugarneArea/Timer.start()

# Modified states for Sakugarne
## Idle state
#func state_idle(_direction: Vector2, _delta: float) -> void:
#	if pogo == true:
#		swapState = STATES.JUMP
#	else:
#		super.state_idle(_direction, _delta)
### Walk state
#func state_walk(_direction: Vector2, _delta: float) -> void:
#	if pogo == true:
#		swapState = STATES.JUMP
#	else:
#		super.state_walk(_direction, _delta)

## Jump state
#func state_jump(_direction: Vector2, _delta: float) -> void:
#	if pogo == true:
#		state_pogo(_direction, _delta)
#	else:
#		super.state_jump(_direction, _delta)
#
#func state_pogo(_direction: Vector2, _delta: float) -> void:
#	if Input.is_action_just_pressed("switch_left") or Input.is_action_just_pressed("switch_right") or GameState.weapon_energy[GameState.WEAPONS.QUINT] < 1:
#		disable_pogo()
	#setup needed on first frame of new state
#	if isFirstFrameOfState:
#		if Input.is_action_pressed("jump"):
#			velocity.y = JUMP_VELOCITY*1.5
#			anim.play("Saku-High")
#			SoundManager.play("player", "jump")
#		else:
#			velocity.y = JUMP_VELOCITY
#			anim.play("Saku-Low")
#			SoundManager.play("player", "jump")
#	#set animation based on falling for rising
#	if velocity.y < 0 && JumpHeight != 80:
#		if (JumpHeight < JUMP_HEIGHT):
#			if Input.is_action_pressed("jump"):
#				velocity.y = JUMP_VELOCITY*1.5
#			else:
#v				velocity.y = JUMP_VELOCITY
#			JumpHeight += 1
#		if (JumpHeight == JUMP_HEIGHT):
#			JumpHeight = 80
#			velocity.y = PEAK_VELOCITY

	#movement in state
#	default_movement(_direction, _delta)

#v	if $SakugarneArea.thing != null and !isFirstFrameOfState:
#		if $SakugarneArea.thing.has_method("_on_hitable_body_entered"):
#			var W_Type = 18 # Sakugarne physical hit
#			$SakugarneArea.thing._on_hitable_body_entered($SakugarneArea)
#v		$SakugarneArea.thing = null
#		swapState = STATES.JUMP
#		ice_jump = false

## Hurt state
#func state_hurt(_direction: Vector2, _delta: float) -> void:
#	disable_pogo()
#	super.state_hurt(_direction, _delta)

## Death state
#func state_dead(_direction: Vector2, _delta: float) -> void:
#	disable_pogo()
#	super.state_dead(_direction, _delta)

## Disable Sakugarne
func disable_pogo():
	pogo = false
	$SakugarneArea.process_mode = Node.PROCESS_MODE_DISABLED
	$SakugarneArea/Timer.stop()
	anim.play("RESET")

func play_start_sound() -> void:
	pass#SoundManager.play("copy_robot", "start")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
