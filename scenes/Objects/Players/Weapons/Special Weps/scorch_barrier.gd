extends CharacterBody2D

const trailscn1 = preload("res://scenes/Objects/Players/Weapons/Special Weps/scorch_barrier_trail_1.tscn")
const trailscn2 = preload("res://scenes/Objects/Players/Weapons/Special Weps/scorch_barrier_trail_2.tscn")

var child1
var child2

const W_Type = 4	# This is Scorch Barrier!!!
const FOLLOW_SPEED = 4.0 # follow speed
var player
@onready var parent = get_parent().get_parent()

var baseposx : int
var baseposy : int

var theta : int

var radius : int

var dist : int

var durability : int
var invul : int


var fired : bool
var left : bool

func _ready():
	$SpawnSound.play()
	durability = 5
	baseposx = position.x
	baseposy = position.y
	theta = rotation
	child1 = trailscn1.instantiate()
	get_parent().add_child(child1)
	child1.position = position
	child2 = trailscn2.instantiate()
	get_parent().add_child(child2)
	child2.position = child1.position
	
	if GameState.character_selected == 0:
		$MainSprite.play("Bass")
	else:
		$MainSprite.play("Copy")
		
func _physics_process(delta):
	child1.position = child1.position.lerp(position, delta * FOLLOW_SPEED)
	child2.position = child2.position.lerp(child1.position, delta * FOLLOW_SPEED)
	
	if invul > 0:
		invul = invul - 1
	else:
		$CollisionShape2D.set_deferred("disabled", false)
	
	theta = theta + 3
	
	if fired == true && GameState.character_selected == 0:
		if left == false:
			dist = dist + 2
			if dist > 10 :
				dist = dist + 2
			if dist > 20 :
				dist = dist + 2
			if dist > 30 :
				dist = dist + 2
		if left == true:
			dist = dist - 2
			if dist < -10 :
				dist = dist - 2
			if dist < -20 :
				dist = dist - 2
			if dist < -30 :
				dist = dist - 2
				
	if fired == true && GameState.character_selected == 1:
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
	
	#20*cos(pitch), 0, 8*sin(-pitch)
	
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if fired == true:
		child1.queue_free()
		child2.queue_free()
		queue_free()

func destroy():
	if invul == 0:
		$HitSound.play()
		
		if durability > 0:
			$CollisionShape2D.set_deferred("disabled", true)
			durability = durability - 1
			invul = 5
		
		if durability < 1:
			$CollisionShape2D.set_deferred("disabled", true)
			velocity.x = 0
			velocity.y = 0
			child1.queue_free()
			child2.queue_free()
			$MainSprite.play("hit")
			await $MainSprite.animation_finished
			queue_free()

func reflect():
	pass	# not reflectable