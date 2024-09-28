extends CharacterBody2D

const trailscn = preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier_trail.tscn")
var trail

var W_Type = 4	# This is Scorch Barrier!!!
const FOLLOW_SPEED = 4.0 # follow speed
var player
@onready var parent = get_parent().get_parent()

var baseposx : int
var baseposy : int

var theta : int

var radius : int

var dist : int

var durability : int = 6
var invul : int
var DmgQueue : int # make the game not crash when you touch an enemy

var speed : int

var wet : bool
var fired : bool
var left : bool

func _ready():
	$SpawnSound.play()
	baseposx = position.x
	baseposy = position.y
	theta = rotation
	animate()
	
		
func _physics_process(_delta):
	if durability < 1:
			$CollisionShape2D.set_deferred("disabled", true)
			velocity.x = 0
			velocity.y = 0
			$MainSprite.play("hit")
			await $MainSprite.animation_finished
			queue_free()
	
	if GameState.current_weapon != 1:
		durability = 0
		
	if GameState.player != null:
		$MainSprite.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
	
	
	if wet == false:
		if durability > 0:
			W_Type = 4
			if ($MainSprite.animation == "Wet"):
				if GameState.character_selected == 2:
					$MainSprite.play("Copy")
				else:
					$MainSprite.play("Bass")
	else:
		if durability > 0:
			W_Type = 2
			$MainSprite.play("Wet")
	
	if invul > 0:
		invul = invul - 1
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		$CollisionShape2D.set_deferred("disabled", false)
	
	if theta < 68:
		theta += 3
		
	else:
		theta = 0
	
	if fired == true && GameState.character_selected != 2: # Bass version
		if left == false:
			dist = dist + 1
			if dist > 10 :
				dist = dist + 1
			if dist > 20 :
				dist = dist + 1
			if dist > 30 :
				dist = dist + 1
		if left == true:
			dist = dist - 1
			if dist < -10 :
				dist = dist - 1
			if dist < -20 :
				dist = dist - 1
			if dist < -30 :
				dist = dist - 1
				
	if fired == true && GameState.character_selected == 2: # Copy Robot version
		radius = radius + 2
		if radius > 30:
			radius = radius + 1
		if radius > 50:
			radius = radius + 1
		if radius > 70:
			radius = radius + 1
	
	if radius < 25:
		radius = radius + 1
		
	position.x = dist + baseposx + cos(theta*0.09)*radius
	position.y = baseposy + sin(theta*0.09)*radius
		
	if ($MainSprite.animation == "Bass" or $MainSprite.animation == "Copy") and ($MainSprite.get_frame() > 0):
		trail = trailscn.instantiate()
		get_parent().add_child(trail)
		trail.position = position
		if $MainSprite.get_frame() == 1:
			trail.set_frame_and_progress(1,0)
	
	
	#20*cos(pitch), 0, 8*sin(-pitch)
	
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if fired == true:
		queue_free()

func destroy():
	if invul == 0:
		$HitSound.play()
		
		if durability > 0:
			$CollisionShape2D.set_deferred("disabled", true)
			durability = durability - 2
			invul = 5

func kill():
	pass

func reflect():
	pass	# not reflectable
	
func animate():
	if GameState.character_selected == 2:
		$MainSprite.play("Copy")
	else:
		$MainSprite.play("Bass")
