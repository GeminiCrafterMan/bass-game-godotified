extends CharacterBody2D

class_name CopyRobotPlayer

@onready var FX
@onready var projectile
@onready var shield
@onready var shield2
@onready var shield3
@onready var shield4

signal jumped(is_ground_jump: bool)
signal dashed(is_ground_dash: bool)
signal hit_ground()

var fall_animator : int

var charge : int
var flash_timer : int

var no_grounded_movement : bool
var is_sliding : bool
var slide_stopped : bool

var slide_timer : int

var shoot_delay = 0
var shot_type = 0
var DmgQueue = 0
var invin_frms = 0

# Change the animation with keeping the frame index and progress.
@onready var current_frame = $AnimatedSprite2D.get_frame()
@onready var current_progress = $AnimatedSprite2D.get_frame_progress()

var teleporting = true
var targetpos : float
signal teleported

var weapon_palette: Array[Texture2D] = [
	preload("res://sprites/Players/Copy Robot/Palettes/None.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Scorch Barrier.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Track 2.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Poison Cloud.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Fin Shredder.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Origami Star.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Wild Gale.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Rolling Bomb.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Boomerang Scythe.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/None.png"), # Proto Shield
	preload("res://sprites/Players/Copy Robot/Palettes/None.png"), # "Treble Boost" (skip it)
	preload("res://sprites/Players/Copy Robot/Palettes/Carry.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Super Arrow.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Mirror Buster.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Screw Crusher.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Ballade Cracker.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/Sakugarne.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/ChargeX1.png"),
	preload("res://sprites/Players/Copy Robot/Palettes/ChargeX2.png")
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
	preload("res://scenes/Objects/Players/Weapons/Special Weps/scorch_barrier.tscn")
]

# Set these to the name of your action (in the Input Map)
## Name of input action to climb up or generally press up.
@export var input_up : String = "move_up"
## Name of input action to climb down or generally press down.
@export var input_down : String = "move_down"
## Name of input action to move left.
@export var input_left : String = "move_left"
## Name of input action to move right.
@export var input_right : String = "move_right"
## Name of input action to jump.
@export var input_jump : String = "jump"
## Name of input action to dash.
@export var input_dash : String = "dash"
## Name of input action to shoot.
@export var input_shoot : String = "shoot"
## Name of input action to fire the buster.
@export var input_buster : String = "buster"
## Name of input actions to switch weapons.
@export var input_switch_left : String = "switch_left"
@export var input_switch_right : String = "switch_right"

const DEFAULT_MAX_JUMP_HEIGHT = 64
const DEFAULT_MIN_JUMP_HEIGHT = 10
const DEFAULT_DOUBLE_JUMP_HEIGHT = 100
const DEFAULT_JUMP_DURATION = 0.4

const ORIGAMI_SPEED = 350
const CRACKER_SPEED = 450

var _max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT
## The max jump height in pixels (holding jump).
@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT: 
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
	
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
			

var _min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT
## The minimum jump height (tapping jump).
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT: 
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)



var _double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT
## The height of your jump in the air.
@export var double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT:
	get:
		return _double_jump_height
	set(value):
		_double_jump_height = value
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		

var _jump_duration: float = DEFAULT_JUMP_DURATION
## How long it takes to get to the peak of the jump in seconds.
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
	
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
		
## Multiplies the gravity by this while falling.
@export var falling_gravity_multiplier = 1.25
## Amount of jumps allowed before needing to touch the ground again. Set to 2 for double jump.
@export var max_jump_amount = 1
@export var max_acceleration = 2500
@export var friction = 30
@export var can_hold_jump : bool = false
## You can still jump this many seconds after falling off a ledge.
@export var coyote_time : float = 0.1
## Pressing jump this many seconds before hitting the ground will still make you jump.
## Only neccessary when can_hold_jump is unchecked.
@export var jump_buffer : float = 0.1


# These will be calcualted automatically
# Gravity will be positive if it's going down, and negative if it's going up
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float


var jumps_left = 0
var holding_jump := false

enum JumpType {NONE, GROUND, AIR}
## The type of jump the player is performing. Is JumpType.NONE if they player is on the ground.
var current_jump_type: JumpType = JumpType.NONE

# Used to detect if player just hit the ground
var _was_on_ground: bool

var acc = Vector2()

# coyote_time and jump_buffer must be above zero to work. Otherwise, godot will throw an error.
@onready var is_coyote_time_enabled = coyote_time > 0
@onready var is_jump_buffer_enabled = jump_buffer > 0
@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()


func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity)
	GameState.max_weapon_energy[9] = 0 # Proto Shield
	GameState.max_weapon_energy[10] = 0 # "Treble Boost"


func _ready():
	GameState.player = self.get_path()
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true

func _input(_event):
	if (teleporting == true):
		return
	if Input.is_action_just_pressed(input_jump):
		if (not Input.is_action_pressed(input_down) or is_sliding == true):
			holding_jump = true
			start_jump_buffer_timer()
			if (not can_hold_jump and can_ground_jump()) or can_double_jump():
				jump()
	
	if Input.is_action_just_released(input_jump):
		holding_jump = false
	
	if Input.is_action_just_pressed(input_switch_left):
		GameState.old_weapon = GameState.current_weapon
		if (GameState.current_weapon == 0):
			GameState.current_weapon = 16
			
		else:
			GameState.current_weapon -= 1
			
			#make sure to clean this up later, I don't wanna -mengo
			# i tried to clean it up, but it ended up working even less... - gem
		if (GameState.current_weapon == 16 && GameState.weapons_unlocked[16] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 15 && GameState.weapons_unlocked[15] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 14 && GameState.weapons_unlocked[14] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 13 && GameState.weapons_unlocked[13] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 12 && GameState.weapons_unlocked[12] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 11 && GameState.weapons_unlocked[11] == false):
			GameState.current_weapon = 9 # skip Treble Boost
		if (GameState.current_weapon == 9 && GameState.weapons_unlocked[9] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 8 && GameState.weapons_unlocked[8] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 7 && GameState.weapons_unlocked[7] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 6 && GameState.weapons_unlocked[6] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 5 && GameState.weapons_unlocked[5] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 4 && GameState.weapons_unlocked[4] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 3 && GameState.weapons_unlocked[3] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 2 && GameState.weapons_unlocked[2] == false):
			GameState.current_weapon -= 1
		if (GameState.current_weapon == 1 && GameState.weapons_unlocked[1] == false):
			GameState.current_weapon -= 1
			
		if GameState.old_weapon != GameState.current_weapon:
			$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])
	
	
	
	if Input.is_action_just_pressed(input_switch_right):
		GameState.old_weapon = GameState.current_weapon
		if (GameState.current_weapon == 16):
			GameState.current_weapon = 0
			
		else:
			GameState.current_weapon += 1
			
		#make sure to clean this up later, I don't wanna -mengo
			# i tried to clean it up, but it ended up working even less... - gem
		if (GameState.current_weapon == 1 && GameState.weapons_unlocked[1] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 2 && GameState.weapons_unlocked[2] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 3 && GameState.weapons_unlocked[3] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 4 && GameState.weapons_unlocked[4] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 5 && GameState.weapons_unlocked[5] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 6 && GameState.weapons_unlocked[6] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 7 && GameState.weapons_unlocked[7] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 8 && GameState.weapons_unlocked[8] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 9 && GameState.weapons_unlocked[9] == false):
			GameState.current_weapon = 11 # skip Treble Boost
		if (GameState.current_weapon == 11 && GameState.weapons_unlocked[11] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 12 && GameState.weapons_unlocked[12] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 13 && GameState.weapons_unlocked[13] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 14 && GameState.weapons_unlocked[14] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 15 && GameState.weapons_unlocked[15] == false):
			GameState.current_weapon += 1
		if (GameState.current_weapon == 16 && GameState.weapons_unlocked[16] == false):
			GameState.current_weapon = 0


		if GameState.old_weapon != GameState.current_weapon:
			$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

	if  (Input.is_action_just_pressed(input_switch_left) && Input.is_action_pressed(input_switch_right)):
		GameState.current_weapon = 0
		if GameState.old_weapon != GameState.current_weapon:
			$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])
	
	if  (Input.is_action_pressed(input_switch_left) && Input.is_action_just_pressed(input_switch_right)):
		GameState.current_weapon = 0
		if GameState.old_weapon != GameState.current_weapon:
			$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

func _physics_process(delta):
	if teleporting == true:
#		$MainHitbox.set_disabled(true)
		if position.y == targetpos or position.y > targetpos:
			position.y = targetpos
			if not $AnimatedSprite2D.animation == "Teleport In":
				$AnimatedSprite2D.play("Teleport In")
				$Audio/WarpInSound.play()
			await $AnimatedSprite2D.animation_finished
			$AnimatedSprite2D.play("Idle")
			teleporting = false
			teleported.emit()
			$Audio/StartSound.play()
#			$MainHitbox.set_disabled(false)
		else:
			position.y += 7
			return
	else:
		if (is_sliding == false || is_feet_on_ground() == false):
			acc.x = 0
			if Input.is_action_pressed(input_left):
				$AnimatedSprite2D.flip_h = true
				acc.x = -max_acceleration
			
			if Input.is_action_pressed(input_right):
				$AnimatedSprite2D.flip_h = false
				acc.x = max_acceleration
		if is_feet_on_ground() and no_grounded_movement == true:
			acc.x = 0
			
		if (is_sliding == true):
			if Input.is_action_pressed(input_left) && $AnimatedSprite2D.flip_h == false:
				if $CeilingCheck.is_colliding() == false:
					is_sliding = false
					slide_timer = 0
					acc.x = -max_acceleration
				else:
					acc.x = -max_acceleration*2
				$AnimatedSprite2D.flip_h = true
				
				
			if Input.is_action_pressed(input_right) && $AnimatedSprite2D.flip_h == true:
				if $CeilingCheck.is_colliding() == false:
					is_sliding = false
					slide_timer = 0
					acc.x = max_acceleration
				else:
					acc.x = max_acceleration*2
				$AnimatedSprite2D.flip_h = false
		if (is_sliding == false):
			handle_weapons()
		weapon_buster()
		do_charge_palette()
		
		if shield != null:
			if $AnimatedSprite2D.flip_h == true:
				shield.baseposx = position.x - 3
			else:
				shield.baseposx = position.x + 3
			
			shield.baseposy = position.y+4
			
		if shield2 != null:
			if $AnimatedSprite2D.flip_h == true:
				shield2.baseposx = position.x - 3
			else:
				shield2.baseposx = position.x + 3
			
			shield2.baseposy = position.y+4
			
		if shield3 != null:
			if $AnimatedSprite2D.flip_h == true:
				shield3.baseposx = position.x - 3
			else:
				shield3.baseposx = position.x + 3
			
			shield3.baseposy = position.y+4
			
		if shield4 != null:
			if $AnimatedSprite2D.flip_h == true:
				shield4.baseposx = position.x - 3
			else:
				shield4.baseposx = position.x + 3
			
			shield4.baseposy = position.y+4
		
		if is_feet_on_ground() and is_sliding:
			$MainHitbox.set_disabled(true)
			$SlideHitbox.set_disabled(false)
			if $CeilingCheck.is_colliding() && slide_timer > 22:
				slide_timer = 22
		else:
			$MainHitbox.set_disabled(false)
			$SlideHitbox.set_disabled(true)

		if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
			jumps_left = max_jump_amount
		if is_feet_on_ground() and current_jump_type == JumpType.NONE:
			start_coyote_timer()
		# Check if we just hit the ground this frame
		if not _was_on_ground and is_feet_on_ground():
			current_jump_type = JumpType.NONE
			if is_jump_buffer_timer_running() and not can_hold_jump: 
				jump()
			hit_ground.emit()
			$Audio/LandSound.play()

	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump and (!Input.is_action_pressed(input_down) or is_sliding == false):
			jump()

	if Input.is_action_pressed(input_down) || is_sliding == true:
		# check this later, might need a small rework
		if can_ground_jump():
			if Input.is_action_just_pressed(input_jump) && slide_stopped == false:
				slide()
	else:
		if not $CeilingCheck.is_colliding():
			is_sliding = false
			slide_timer = 0
	if slide_stopped == false:
		check_slide()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity
	
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta
	
	_was_on_ground = is_feet_on_ground()
	move_and_slide()
	
	animate()

## Use this instead of coyote_timer.start() to check if the coyote_timer is enabled first
func start_coyote_timer():
	if is_coyote_time_enabled:
		coyote_timer.start()

## Use this instead of jump_buffer_timer.start() to check if the jump_buffer is enabled first
func start_jump_buffer_timer():
	if is_jump_buffer_enabled:
		jump_buffer_timer.start()

## Use this instead of `not coyote_timer.is_stopped()`. This will always return false if 
## the coyote_timer is disabled
func is_coyote_timer_running():
	if (is_coyote_time_enabled and not coyote_timer.is_stopped()):
		return true
	
	return false

## Use this instead of `not jump_buffer_timer.is_stopped()`. This will always return false if 
## the jump_buffer_timer is disabled
func is_jump_buffer_timer_running():
	if is_jump_buffer_enabled and not jump_buffer_timer.is_stopped():
		return true
	
	return false


func can_ground_jump() -> bool:
	if jumps_left > 0 and current_jump_type == JumpType.NONE:
		return true
	elif is_coyote_timer_running():
		return true
	
	return false


func can_double_jump():
	if jumps_left <= 1 and jumps_left == max_jump_amount:
		# Special case where you've fallen off a cliff and only have 1 jump. You cannot use your
		# first jump in the air
		return false
	
	if jumps_left > 0 and not is_feet_on_ground() and coyote_timer.is_stopped():
		return true
	
	return false


## Same as is_on_floor(), but also returns true if gravity is reversed and you are on the ceiling
func is_feet_on_ground():
	if is_on_floor() and default_gravity >= 0:
		return true
	if is_on_ceiling() and default_gravity <= 0:
		return true
	is_sliding = false
	slide_timer = 0
	return false


## Perform a ground jump, or a double jump if the character is in the air.
func jump():
	if can_double_jump():
		double_jump()
	elif is_feet_on_ground():
		ground_jump()

## Perform a double jump without checking if the player is able to.
func double_jump():
	if jumps_left == max_jump_amount:
		# Your first jump must be used when on the ground.
		# If your first jump is used in the air, an additional jump will be taken away.
		jumps_left -= 1
	
	velocity.y = -double_jump_velocity
	current_jump_type = JumpType.AIR
	jumps_left -= 1
	jumped.emit(false)


## Perform a ground jump without checking if the player is able to.
func ground_jump():
	if $CeilingCheck.is_colliding() == false or is_sliding == false:
		velocity.y = -jump_velocity
		current_jump_type = JumpType.GROUND
		jumps_left -= 1
		coyote_timer.stop()
		$Audio/JumpSound.play()
		jumped.emit(true)

## Perform a ground dash, or an air dash if... we ever add that?
func slide():
	if (is_sliding == false):
		$Audio/SlideSound.play()
		is_sliding = true
		FX = preload("res://scenes/Objects/Players/dashtrail.tscn").instantiate()
		get_parent().add_child(FX)
		if $AnimatedSprite2D.flip_h:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8
		ground_slide()

## Perform a ground dash without checking if the player is able to.
func ground_slide():
	if ($AnimatedSprite2D.flip_h == false):
		acc.x = max_acceleration*2
	else:
		acc.x = -max_acceleration*2

func check_slide():
	if slide_timer > 24:
		is_sliding = false
		slide_timer = 0
		slide_stopped = true
		
		acc.x = 0
	
		if Input.is_action_pressed(input_left):
				$AnimatedSprite2D.flip_h = true
				acc.x = -max_acceleration
		
		if Input.is_action_pressed(input_right):
			$AnimatedSprite2D.flip_h = false
			acc.x = max_acceleration
		
	if is_sliding == true:
		slide_timer = slide_timer + 1

func apply_gravity_multipliers_to(gravity) -> float:
	if velocity.y * sign(default_gravity) > 0: # If we are falling
		gravity *= falling_gravity_multiplier
	
	# if we released jump and are still rising
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump: 
			if not current_jump_type == JumpType.AIR: # Always jump to max height when we are using a double jump
				gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
	return gravity

## Calculates the desired gravity from jump height and jump duration.  [br]
## Formula is from [url=https://www.youtube.com/watch?v=hG9SzQxaCm8]this video[/url] 
func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)

## Calculates the desired jump velocity from jump height and jump duration.
func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)

## Calculates jump velocity from jump height and gravity.  [br]
## Formula from 
## [url]https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du[/url]
func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)

## Calculates the gravity when the key is released based off the minimum jump height and jump velocity.  [br]
## Formula is from [url]https://sciencing.com/acceleration-velocity-distance-7779124.html[/url]
func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity

## Returns a value for friction that will hit the max speed after 90% of time_to_max seconds.  [br]
## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)

## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed

func animate():
	current_frame = $AnimatedSprite2D.get_frame()
	current_progress = $AnimatedSprite2D.get_frame_progress()
	if (is_feet_on_ground() == true):
		if (is_sliding):
			$AnimatedSprite2D.play("Slide")
			return
		if (abs(velocity.x) == 0):
			if shoot_delay == 0:
				$AnimatedSprite2D.play("Idle")
			else:
				match shot_type:
					0: # Normal
						$AnimatedSprite2D.play("Idle-Shoot")
					2: # Throw
						$AnimatedSprite2D.play("Idle-Throw")
					3: # Shield
						$AnimatedSprite2D.play("Idle-Shield")
					4: # Double Reppuken
						$AnimatedSprite2D.play("Double Reppuken")
					_: # Everything else
						$AnimatedSprite2D.play("Idle-Shoot")
			slide_stopped = false
		else:
			if (abs(velocity.x) > 50):
				slide_stopped = false
				if shoot_delay == 0:
					$AnimatedSprite2D.play("Walk")
					$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
				else:
					match shot_type:
						0: # Normal
							$AnimatedSprite2D.play("Walk-Shoot")
							$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
						2: # Throw
							$AnimatedSprite2D.play("Idle-Throw")
						3: # Shield
							$AnimatedSprite2D.play("Idle-Shield")
						4: # Double Reppuken
							$AnimatedSprite2D.play("Double Reppuken")
						_: # Everything else
							$AnimatedSprite2D.play("Walk-Shoot")
							$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
			else:
				if shoot_delay == 0:
					$AnimatedSprite2D.play("Step")
				else:
					match shot_type:
						0: # Normal
							$AnimatedSprite2D.play("Idle-Shoot")
						2: # Throw
							$AnimatedSprite2D.play("Idle-Throw")
						3: # Shield
							$AnimatedSprite2D.play("Idle-Shield")
						4: # Double Reppuken
							$AnimatedSprite2D.play("Double Reppuken")
						_: # Everything else
							$AnimatedSprite2D.play("Idle-Shoot")
				slide_stopped = false
	else:
		if shoot_delay == 0:
			if (velocity.y < 0):
				$AnimatedSprite2D.play("Jump")
				fall_animator = 0
			if (velocity.y > 0):
				fall_animator = fall_animator + 1
				if  fall_animator < 4:
					$AnimatedSprite2D.play("Jump Transition")
				else:
					$AnimatedSprite2D.play("Fall")
		else:
			match shot_type:
				0: # Normal
					$AnimatedSprite2D.play("Jump-Shoot")
				2: # Throw
					$AnimatedSprite2D.play("Jump-Throw")
				3: # Shield
					$AnimatedSprite2D.play("Jump-Shield")
				4: # Double Reppuken
					$AnimatedSprite2D.play("Jump-Throw")
				_: # Everything else
					$AnimatedSprite2D.play("Jump-Shoot")

func do_charge_palette():
	if charge == 0 or charge < 37: # no charge
		$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
	elif charge >= 37 && charge < 65: # just started charging
		if flash_timer == 2 || flash_timer == 3:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[17])
			flash_timer += 1
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			flash_timer += 1
		if flash_timer == 3:
			flash_timer = 0
	elif charge >= 65 && charge < 92:
		if flash_timer == 1:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[17])
			flash_timer = 0
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			flash_timer = 1
	elif charge >= 92:
		if flash_timer == 1:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[18])
			flash_timer = 0
		else:
			$AnimatedSprite2D.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			flash_timer = 1

func handle_weapons():
	match GameState.current_weapon:
		1:
			weapon_blaze()
		3:
			weapon_smog()
		5:
			weapon_origami()
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
		if is_sliding == false:
			shot_type = 0
			shoot_delay = 13
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if $AnimatedSprite2D.flip_h:
				projectile.velocity.x = -350
				projectile.scale.x = -1
			else:
				projectile.velocity.x = 350
			charge = 0
			return
	if (GameState.current_weapon == 0 and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if is_sliding == false:
			if charge < 32: # no charge
				charge = 0
				return
			if charge >= 32 and charge < 92: # medium charge
				shot_type = 0
				shoot_delay = 13
				projectile = projectile_scenes[1].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -450
					projectile.scale.x = -1
				else:
					projectile.velocity.x = 450
				charge = 0
				return
			if charge >= 92: # da big boi
				shot_type = 0
				shoot_delay = 13
				projectile = projectile_scenes[2].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -450
					projectile.scale.x = -1
				else:
					projectile.velocity.x = 450
				charge = 0
				return
	if (GameState.current_weapon == 0 and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
		if charge < 100:
			charge += 1
			if charge == 32:
				$Audio/Charge1.play()
			if charge == 99:
				$Audio/Charge2.play()
			
	else:
		charge = 0
		return

func weapon_blaze():
	if shoot_delay > 0:
		if shot_type == 2 or shot_type == 3:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false

	if Input.is_action_just_pressed(input_shoot):
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
				if $AnimatedSprite2D.flip_h == true:
					shield.left = true
			if shield2 != null:
				shield2.fired = true
				if $AnimatedSprite2D.flip_h == true:
					shield2.left = true
			if shield3 != null:
				shield3.fired = true
				if $AnimatedSprite2D.flip_h == true:
					shield3.left = true
			if shield4 != null:
				shield4.fired = true
				if $AnimatedSprite2D.flip_h == true:
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

	if Input.is_action_just_pressed(input_shoot):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 13
		projectile = weapon_scenes[1].instantiate()
		get_parent().add_child(projectile)
		if $AnimatedSprite2D.flip_h:
			projectile.position.x = position.x - 14
		else:
			projectile.position.x = position.x + 14
		
		projectile.position.y = position.y + 4
		if $AnimatedSprite2D.flip_h:
			projectile.velocity.x = -200
		else:
			projectile.velocity.x = 200
		if $AnimatedSprite2D.flip_h:
			projectile.scale.x = -1
		# inputs
		
		is_sliding = false
		return

func weapon_origami():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed(input_shoot):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 13
		projectile = weapon_scenes[0].instantiate()
			
		#SHOOT FORWARD 
		if !Input.is_action_pressed(input_up) && !Input.is_action_pressed(input_down):
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			# inputs
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED
			else:
				projectile.velocity.x = ORIGAMI_SPEED
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.775
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.775
			projectile.velocity.y = -ORIGAMI_SPEED * 0.225
					
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.775
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
	
		if Input.is_action_pressed(input_up):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED *  0.225
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.225
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.5
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.775
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  -ORIGAMI_SPEED * 0.225
			
		if Input.is_action_pressed(input_down):
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED *  0.225
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.225
			projectile.velocity.y =  ORIGAMI_SPEED * 0.775
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.5
			else:
					projectile.velocity.x = ORIGAMI_SPEED * 0.5
			projectile.velocity.y =  ORIGAMI_SPEED * 0.5
			
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			if !$AnimatedSprite2D.flip_h:
				projectile.scale.x = -1
			if $AnimatedSprite2D.flip_h:
					projectile.velocity.x = -ORIGAMI_SPEED * 0.775
			else:
				projectile.velocity.x = ORIGAMI_SPEED * 0.775
			projectile.velocity.y =  ORIGAMI_SPEED * 0.225
		
		return

func weapon_carry():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
			no_grounded_movement = true
	else:
		no_grounded_movement = false
	if Input.is_action_just_pressed(input_shoot):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 2
		shoot_delay = 13
		projectile = projectile_scenes[3].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		if is_feet_on_ground():	
			projectile.position.y = position.y
			if $AnimatedSprite2D.flip_h:
				projectile.position.x = position.x - 30
			else:
				projectile.position.x = position.x + 30
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
	if Input.is_action_just_pressed(input_shoot):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		shot_type = 1
		shoot_delay = 13
		projectile = projectile_scenes[6].instantiate()
		
		#SHOOT FORWARD REGARDLESS
		get_parent().add_child(projectile)
		projectile.position.y = position.y
		if $AnimatedSprite2D.flip_h:
			velocity.x = -1
			projectile.position.x = position.x - 27
		else:
			velocity.y = -1
			projectile.scale.x = -1
			projectile.position.x = position.x + 27


func weapon_punk():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
		no_grounded_movement = true
	else:
		no_grounded_movement = false
		
	if Input.is_action_just_pressed(input_shoot):
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
		
		if $AnimatedSprite2D.flip_h:
			projectile.velocity.x = -95
		else:
			projectile.velocity.x = 95
	return


func weapon_ballade():
	if shoot_delay > 0:
		if shot_type == 2:
			shoot_delay -= 1
		no_grounded_movement = true
	else:
		no_grounded_movement = false
		
	if Input.is_action_just_pressed(input_shoot):
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		
		shot_type = 2
		shoot_delay = 13
		projectile = projectile_scenes[4].instantiate()
		
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		projectile.velocity.y = 0
		if $AnimatedSprite2D.flip_h:
			projectile.velocity.x = -CRACKER_SPEED * 1
		else:
			projectile.velocity.x = CRACKER_SPEED * 1
			
		if(Input.is_action_pressed(input_up)):
			projectile.velocity.y = -CRACKER_SPEED * 0.5
			if $AnimatedSprite2D.flip_h:
				projectile.velocity.x = -CRACKER_SPEED * 0.5
			else:
				projectile.velocity.x = CRACKER_SPEED * 0.5
			
		if(Input.is_action_pressed(input_up) && !Input.is_action_pressed(input_left) && !Input.is_action_pressed(input_right)):
			projectile.velocity.y = -CRACKER_SPEED * 1
			projectile.velocity.x = 0
						
		if(Input.is_action_pressed(input_down)):
			projectile.velocity.y = CRACKER_SPEED * 0.5
			if $AnimatedSprite2D.flip_h:
				projectile.velocity.x = -CRACKER_SPEED * 0.5
			else:
				projectile.velocity.x = CRACKER_SPEED * 0.5
			return

func _DamageAndInvincible():
	if invin_frms > 0:
		invin_frms -= 1
		if invin_frms % 2 == 0:
			visible = false
		else:
			visible = true
	else:
		visible = true
	if DmgQueue > 0:
		if invin_frms > 0:
			DmgQueue = 0
		else:
			GameState.current_hp -= DmgQueue
			DmgQueue = 0
			$Audio/owchj.play()
