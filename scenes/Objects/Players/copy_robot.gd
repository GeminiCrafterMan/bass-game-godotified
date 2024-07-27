extends CharacterBody2D

class_name CopyRobotPlayer

signal jumped(is_ground_jump: bool)
signal dashed(is_ground_dash: bool)
signal hit_ground()

var fall_animator : int

var is_sliding : bool
var slide_stopped : bool

var slide_timer : int

var current_weapon : int
#var old_weapon : int

var teleporting = true
var targetpos : float

var weapon_palette = [
	"res://sprites/Players/Copy Robot/Palettes/None.png",
	"res://sprites/Players/Copy Robot/Palettes/Scorch Barrier.png",
	"res://sprites/Players/Copy Robot/Palettes/Track 2.png",
	"res://sprites/Players/Copy Robot/Palettes/Poison Cloud.png",
	"res://sprites/Players/Copy Robot/Palettes/Fin Shredder.png",
	"res://sprites/Players/Copy Robot/Palettes/Origami Star.png",
	"res://sprites/Players/Copy Robot/Palettes/None.png", # Gale ???
	"res://sprites/Players/Copy Robot/Palettes/None.png", # ???
	"res://sprites/Players/Copy Robot/Palettes/None.png", # ???
	"res://sprites/Players/Copy Robot/Palettes/None.png", # Proto Shield
	"res://sprites/Players/Copy Robot/Palettes/None.png", # "Treble Boost" (skip it)
	"res://sprites/Players/Copy Robot/Palettes/Carry.png",
	"res://sprites/Players/Copy Robot/Palettes/Super Arrow.png",
	"res://sprites/Players/Copy Robot/Palettes/Mirror Buster.png",
	"res://sprites/Players/Copy Robot/Palettes/Screw Crusher.png",
	"res://sprites/Players/Copy Robot/Palettes/Ballade Cracker.png",
	"res://sprites/Players/Copy Robot/Palettes/Sakugarne.png"
]
var charge_palette = [
	"res://sprites/Players/Copy Robot/Palettes/None.png",
	"res://sprites/Players/Copy Robot/Palettes/Charge 1.png",
	"res://sprites/Players/Copy Robot/Palettes/Charge 2.png",
	"res://sprites/Players/Copy Robot/Palettes/Charge 3.png",
	"res://sprites/Players/Copy Robot/Palettes/Charge Release.png"
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
## Name of input actions to switch weapons.
@export var input_switch_left : String = "switch_left"
@export var input_switch_right : String = "switch_right"

const DEFAULT_MAX_JUMP_HEIGHT = 80
const DEFAULT_MIN_JUMP_HEIGHT = 10
const DEFAULT_DOUBLE_JUMP_HEIGHT = 100
const DEFAULT_JUMP_DURATION = 0.4

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


var jumps_left : int
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


func _ready():
	await Fade.fade_in()

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
		
	
	if (is_sliding == false || is_feet_on_ground() == false):
		acc.x = 0
		if Input.is_action_pressed(input_left):
			$AnimatedSprite2D.flip_h = true
			acc.x = -max_acceleration
		
		if Input.is_action_pressed(input_right):
			$AnimatedSprite2D.flip_h = false
			acc.x = max_acceleration
			
	if (is_sliding == true):
		if Input.is_action_pressed(input_left) && $AnimatedSprite2D.flip_h == false:
			is_sliding = false
			slide_timer = 0
			
		if Input.is_action_pressed(input_right) && $AnimatedSprite2D.flip_h == true:
			is_sliding = false
			slide_timer = 0
	
	if Input.is_action_just_released(input_jump):
		holding_jump = false
	
	if Input.is_action_just_pressed(input_switch_left):
		if (current_weapon == 11):
			current_weapon = 9
		if (current_weapon == 0):
			current_weapon = 16
		else:
			current_weapon = current_weapon - 1
		$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette",load(weapon_palette[current_weapon]))
	
	if Input.is_action_just_pressed(input_switch_right):
		if (current_weapon == 9):
			current_weapon = 11
		if (current_weapon == 16):
			current_weapon = 0
		else:
			current_weapon = current_weapon + 1
		$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette",load(weapon_palette[current_weapon]))

	if  (Input.is_action_just_pressed(input_switch_left) && Input.is_action_pressed(input_switch_right)):
		current_weapon = 0
		$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette",load(weapon_palette[current_weapon]))
	
	if  (Input.is_action_pressed(input_switch_left) && Input.is_action_just_pressed(input_switch_right)):
		current_weapon = 0
		$Audio/SwitchSound.play()
		$AnimatedSprite2D.material.set_shader_parameter("palette",load(weapon_palette[current_weapon]))

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
#			$MainHitbox.set_disabled(false)
		else:
			position.y = position.y + 7
			return

	if is_feet_on_ground() and is_sliding:
		$MainHitbox.set_disabled(true)
		$SlideHitbox.set_disabled(false)
		if $CeilingCheck.is_colliding():
			slide_timer = 10
	else:
		$MainHitbox.set_disabled(false)
		$SlideHitbox.set_disabled(true)

	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
	
	if teleporting == false:
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

	if Input.is_action_pressed(input_down):
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
	$Audio/JumpSound.play()
	if can_double_jump():
		double_jump()
	else:
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
	velocity.y = -jump_velocity
	current_jump_type = JumpType.GROUND
	jumps_left -= 1
	coyote_timer.stop()
	jumped.emit(true)

## Perform a ground dash, or an air dash if... we ever add that?
func slide():
	if (is_sliding == false):
		$Audio/SlideSound.play()
		is_sliding = true
		ground_slide()

## Perform a ground dash without checking if the player is able to.
func ground_slide():
	if ($AnimatedSprite2D.flip_h == false):
		acc.x = max_acceleration*2
	else:
		acc.x = -max_acceleration*2

func check_slide():
	if slide_timer > 25:
		is_sliding = false
		slide_timer = 0
		slide_stopped = true
		acc.x = 0
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
	if (is_feet_on_ground() == true):
		if (is_sliding):
			$AnimatedSprite2D.play("Slide")
			return
		if (abs(velocity.x) == 0):
			$AnimatedSprite2D.play("Idle")
			slide_stopped = false
		else:
			if (abs(velocity.x) > 50):
				$AnimatedSprite2D.play("Walk")
			else:
				$AnimatedSprite2D.play("Step")
				slide_stopped = false
	else:
		if (velocity.y < 0):
			$AnimatedSprite2D.play("Jump")
			fall_animator = 0
		if (velocity.y > 0):
			fall_animator = fall_animator + 1
			if  fall_animator < 4:
				$AnimatedSprite2D.play("Jump Transition")
			else:
				$AnimatedSprite2D.play("Fall")

# lol i plucked this from the example for .play(), this'll be useful for firing anims
# Change the animation with keeping the frame index and progress.
#var current_frame = $AnimatedSprite2D.get_frame()
#var current_progress = $AnimatedSprite2D.get_frame_progress()
#$AnimatedSprite2D.play("Walk-Shoot")
#$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
