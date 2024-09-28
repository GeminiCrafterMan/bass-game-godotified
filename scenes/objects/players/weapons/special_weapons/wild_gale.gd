extends CharacterBody2D

const W_Type = 9	# This is Wild Gale.
var wait : int
@onready var visuals
var direction : int

func _ready():
	visuals = preload("res://scenes/objects/players/weapons/special_weapons/wild_gale_visuals.tscn").instantiate()
	visuals.direction = direction
	get_parent().add_child(visuals)
	$SpawnSound.play()
		
func _physics_process(delta):
	if wait > 30:
		queue_free()
	wait = wait + 1

func destroy():
	pass

func reflect():
	pass
	
