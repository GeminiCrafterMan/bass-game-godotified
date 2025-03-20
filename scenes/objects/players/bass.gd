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
	dashing = false
	slowed = true
	ice_jump = false
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


func _on_teleported() -> void:
	pass # Replace with function body.
