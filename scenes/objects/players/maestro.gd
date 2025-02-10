extends CharacterBody2D

class_name MaestroPlayer

#region Signals
signal teleported
#endregion

#region Enums
enum STATES {
	NONE,
	TELEPORT,
	TELEPORT_LANDING,
	IDLE,
	STEP,
	WALK,
	SLIDE,
	JUMP,
	JUMP_TRANS,
	FALL,
	FALL_SHOOT,
	LADDER,
	HURT,
	IDLE_SHOOT,
	WALKING_SHOOT,
	LADDER_SHOOT,
	JUMP_SHOOT,
	IDLE_THROW,
	JUMP_THROW,
	FALL_THROW,
	IDLE_SHIELD,
	JUMP_SHIELD,
	FALL_SHIELD,
	DEAD
}

enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}

#endregion

# state related
var currentState := STATES.TELEPORT
var currentWeapon := WEAPONS.BUSTER
var swapState := STATES.NONE
var numberOfTimesToRunStates := 0
var isFirstFrameOfState := false
var targetpos : float
var currentSpeed := 0
var fallstored : float
var slowed : bool
var direction
var canLadder : bool
var ladderArea
var underRoof : bool
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
#@onready var top_ladder_check: RayCast2D = $LadderCheck1
#@onready var bottom_ladder_check: RayCast2D = $LadderCheck2
#@onready var floor_ladder_check: RayCast2D = $LadderCheck3
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
@onready var hurtbox = $hurtboxArea
@onready var shoot_timer = $ShootTimer
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
var wind_push = 0

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
	preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/wild_gale.tscn")
]

func _ready():
	GameState.player = self
	GameState.onscreen_bullets = 0
	GameState.onscreen_sp_bullets = 0
	state_timer.start(0.5)
	invul_timer.start(0.01)
	currentState = STATES.TELEPORT
	SoundManager.play("player", "warp")
	print(GameState.current_hp)

#So basically what this new state machine does is that it organizes every state into a little chunk that'll execute the functions it's meant to each frame. This way you won't need to have the
#function that applies gravity need to specify to only apply it during certain states since it will only execute on the correct states. It's also just nicer to look at.

func _physics_process(delta: float) -> void:
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
	match currentState:
		STATES.TELEPORT, STATES.TELEPORT_LANDING:
			teleporting()
			applyGrav(delta)
		STATES.IDLE, STATES.IDLE_SHOOT:
			idle(delta)
			slideProcess()
			checkForFloor()
			processJump()
			switchWeapons()
			processShoot()
			processCharge()
			ladderCheck()
		STATES.IDLE_THROW:
			velocity.x = 0
			checkForFloor()
		STATES.IDLE_SHIELD:
			velocity.x = 0
			checkForFloor()
		STATES.STEP:
			step(delta)
			checkForFloor()
			slideProcess()
			processJump()
			processShoot()
			processCharge()
			ladderCheck()
		STATES.WALK, STATES.WALKING_SHOOT:
			walk()
			slideProcess()
			checkForFloor()
			processJump()
			allowLeftRight(delta)
			processShoot()
			processCharge()
			ladderCheck()
		STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD:
			Jump()
			applyGrav(delta)
			allowLeftRight(delta)
			processShoot()
			processCharge()
			ladderCheck()
		STATES.FALL, STATES.FALL_SHOOT, STATES.FALL_THROW, STATES.FALL_SHIELD:
			fall()
			applyGrav(delta)
			allowLeftRight(delta)
			processShoot()
			processCharge()
			ladderCheck()
		STATES.SLIDE:
			sliding()
			processJump()
			processCharge()
			ladderCheck()
		STATES.LADDER:
			ladder()
			processCharge()
		STATES.HURT:
			hurt()
			applyGrav(delta)
		STATES.DEAD:
			dead()
	animationMatching()
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
	else:
		if velocity.y != 0:
			fallstored = velocity.y
			velocity.y = 0
	position.x += wind_push

func teleporting():
	if is_on_floor() && currentState == STATES.TELEPORT:
		currentState = STATES.TELEPORT_LANDING

func idle(delta):
	if direction.x != 0 && velocity.x == 0:
		if currentState == STATES.IDLE or currentState == STATES.IDLE_SHOOT:
			position.x += direction.x
			velocity.x = 0
			StepTime = 0
			currentState = STATES.STEP
	if direction.x == 0 && on_ice == true:
		velocity.x = lerpf(velocity.x, 0, delta * 2)
	else:
		velocity.x = 0

func step(delta):
	StepTime += 1
	if direction.x == 0:
		currentState = STATES.IDLE
	else:
		sprite.scale.x = direction.x
	if StepTime > 6:
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
							velocity.x = lerpf(velocity.x, direction.x * MAXSPEED, delta * 3)
					else:
						currentSpeed = MAXSPEED
				if is_on_floor() == true && on_ice == true:
					velocity.x = lerpf(velocity.x, direction.x * MAXSPEED*1.5, delta * 2)
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
		currentState = STATES.FALL

func processJump():
	if Input.is_action_just_pressed("jump") && direction.y != -1:
		velocity.y = JUMP_VELOCITY
		currentState = STATES.JUMP
		JumpHeight = 0
		SoundManager.play("player", "jump")

func Jump():
	if velocity.y < 0 && JumpHeight != 80:
		if (JumpHeight < JUMP_HEIGHT && Input.is_action_pressed("jump")):
			velocity.y = JUMP_VELOCITY
			JumpHeight += 1
		if (JumpHeight == JUMP_HEIGHT):
			JumpHeight = 80
			velocity.y = PEAK_VELOCITY
			currentState = STATES.FALL
		if (Input.is_action_just_released("jump")):
			JumpHeight = 80
			velocity.y = STOP_VELOCITY
			currentState = STATES.FALL
	if direction.x == 0:
		velocity.x = 0
	if is_on_ceiling():
		JumpHeight = 80
		velocity.y = STOP_VELOCITY
		currentState = STATES.FALL

func fall():
	if direction.x == 0:
		velocity.x = 0
	if is_on_floor():
		if direction.x != 0:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE

func ladderCheck():
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
		currentState = STATES.FALL


func _on_collision_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("touching ladder!")

func _on_collision_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("not touching ladder...")

func slideProcess():
	if direction.y == -1 && Input.is_action_just_pressed("jump"):
		velocity.x = 200 * sprite.scale.x
		currentState = STATES.SLIDE
		$mainCollision.disabled = true
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

func sliding():
	if direction.x != 0:
		velocity.x = 200 * direction.x
		sprite.scale.x = direction.x
	if !is_on_floor():
		velocity.x = 0
		currentState = STATES.FALL
	if Input.is_action_just_pressed("jump"):
		$mainCollision.disabled = true

func _on_slide_timer_timeout() -> void:
	if $ceilCheck.is_colliding():
		print("keep sliding")
		slide_timer.start(0.1)
	else:
		velocity.x = 0
		currentState = STATES.IDLE
		$mainCollision.disabled = false

func _on_hurtbox_area_area_entered(area: Area2D) -> void:
	print("wee")
	if area.is_in_group("hitbox"):
		hitByThing()

func hitByThing():
	invul(true)
	pain_timer.start()
	GameState.current_hp -= DmgQueue
	if GameState.current_hp >= 0:
		currentState = STATES.HURT
		velocity.x = sprite.scale.x * -20
		if is_on_floor():
			velocity.y = -70
		else:
			velocity.y = -90
	else:
		currentState = STATES.DEAD
		SoundManager.play("player", "hurt")

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


#func _DamageAndInvincible():
	#if !invul_timer.is_stopped():
		#InvincFrames += 1
		#if InvincFrames >= 2:
			#sprite.visible = false
		#if InvincFrames == 3:
			#InvincFrames = 0
			#sprite.visible = true
	#else:
		#sprite.visible = true
	#if DmgQueue > 0:
		#if !invul_timer.is_stopped():
			#DmgQueue = 0
		#else:
			#if GameState.current_hp - DmgQueue > 0:
				#GameState.current_hp -= DmgQueue
			#else:
				#GameState.current_hp = 0
			#DmgQueue = 0
			#currentState = STATES.HURT
			#if GameState.current_hp <= 0:
				#currentState = STATES.DEAD
			#invul_timer.start(1)
			#pain_timer.start(0.55)

func dead():
	$MainHitbox.set_disabled(true)
	$SlideHitbox.set_disabled(true)
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

#STATES.keys()[currentState]

func stopTeleportingFuckingIdiot():
	currentState = STATES.IDLE

func animationMatching():
	if anim.current_animation != STATES.keys()[currentState]:
		anim.play(STATES.keys()[currentState])

func busterAnimMatch():
	$ShootTimer.start()
	if currentState == STATES.IDLE or currentState == STATES.STEP:
		currentState = STATES.IDLE_SHOOT
	elif currentState == STATES.WALK:
		var getFrame = anim.current_animation_position
		currentState = STATES.WALKING_SHOOT
		anim.seek(getFrame)
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHOOT
	elif currentState == STATES.FALL:
		currentState = STATES.FALL_SHOOT

func shieldAnimMatch():
	$ShootTimer.start()
	if currentState == STATES.IDLE or currentState == STATES.STEP or currentState == STATES.WALK:
		currentState = STATES.IDLE_SHIELD
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHIELD
	elif currentState == STATES.FALL:
		currentState = STATES.FALL_SHIELD

func throwAnimMatch():
	$ShootTimer.start()
	if currentState == STATES.IDLE or currentState == STATES.STEP or currentState == STATES.WALK:
		currentState = STATES.IDLE_THROW
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_THROW
	elif currentState == STATES.FALL:
		currentState = STATES.FALL_THROW

func _on_shoot_timer_timeout() -> void:
	if STATES.keys()[currentState].contains("IDLE"):
		currentState = STATES.IDLE
	elif STATES.keys()[currentState].contains("WALK"):
		var getFrame = anim.current_animation_position
		currentState = STATES.WALK
		anim.seek(getFrame)
	elif STATES.keys()[currentState].contains("JUMP"):
		currentState = STATES.JUMP
	elif STATES.keys()[currentState].contains("FALL"):
		currentState = STATES.FALL
	elif currentState == STATES.IDLE_THROW:
		currentState = STATES.IDLE

#region Weapon Shit
func processShoot():
	if Input.is_action_just_pressed("shoot") && transing != true:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.BUSTER:
				busterAnimMatch()
				weapon_buster()
			WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			WEAPONS.SMOG:
				busterAnimMatch()
				weapon_smog()
			WEAPONS.SHARK:
				throwAnimMatch()
				weapon_shark()
			WEAPONS.ORIGAMI:
				throwAnimMatch()
				weapon_origami()
			WEAPONS.GALE:
				shieldAnimMatch()
				weapon_gale()
			WEAPONS.GUERRILLA:
				busterAnimMatch()
				weapon_guerilla()
			WEAPONS.CARRY:
				throwAnimMatch()
				weapon_carry()
			WEAPONS.ARROW:
				busterAnimMatch()
				weapon_arrow()
			WEAPONS.PUNK:
				weapon_punk()
			WEAPONS.BALLADE:
				throwAnimMatch()
				weapon_ballade()
			WEAPONS.QUINT:
				weapon_quint()
#i dunno where the purple goes

func processCharge():
	if Input.is_action_pressed("shoot") && transing != true:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.REAPER:
				weapon_reaper()
	elif Input.is_action_just_released("shoot") && transing != true:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.REAPER:
				throwAnimMatch()
				weapon_reaper()

func weapon_buster():
	if GameState.onscreen_bullets < 3:
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

func weapon_blaze():
	if Input.is_action_just_pressed("shoot") and transing != true:
		var space : int = 18
		if shield == null && shield2 == null && shield3 == null && shield4 == null && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
			shot_type = 3
			anim.seek(0)
			attack_timer.start(0.5)
			shieldAnimMatch()
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield = weapon_scenes[2].instantiate()
				add_child(shield)
				shield.theta = 0*space
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 3 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield2 = weapon_scenes[2].instantiate()
				add_child(shield2)
				shield2.theta = 1*space
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 2 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield3 = weapon_scenes[2].instantiate()
				add_child(shield3)
				shield3.theta = 2*space
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 4 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield4 = weapon_scenes[2].instantiate()
				add_child(shield4)
				shield4.theta = 3*space
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[WEAPONS.BLAZE] -= 4
			#print(get_children())
		else:
			if shield or shield2 or shield3 or shield4:
				throwAnimMatch()
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

func weapon_gale():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.GALE] >= 7 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 1:
		if transing != true:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.GALE] -= 7
			anim.seek(0)
			GameState.onscreen_sp_bullets = 1
			shot_type = 3
			attack_timer.start(0.5)
			projectile = weapon_scenes[7].instantiate()
			
			get_parent().add_child(projectile)
			projectile.position.x = GameState.camposx + (-280 * sprite.scale.x) 
			projectile.position.y = GameState.camposy
			
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = sprite.scale.x
			
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

func switchWeapons():
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

func set_current_weapon_palette() -> void:
	sprite.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

#endregion

func reset(everything: bool) -> void:
	GameState.refill_health()
	GameState.current_weapon = GameState.WEAPONS.BUSTER # Reset current weapon
	if everything == true:
		GameState.refill_ammo()

#func ice_jump_move(direction, delta):
	##movement in state
	#if direction.x:
		#sprite.scale.x = sign(direction.x)
		#if (direction.x == -1 && velocity.x > 20) or (direction.x == 1 && velocity.x < -20):
			#velocity.x = lerpf(velocity.x, 0, delta * 7)
		#else:
			#if (direction.x == 1 && velocity.x < 30) or (direction.x == -1 && velocity.x > -30):
				#velocity.x = lerpf(direction.x * 50, 0, delta * 7)
	#else:
		#velocity.x = lerpf(velocity.x, 0, delta * 4)
