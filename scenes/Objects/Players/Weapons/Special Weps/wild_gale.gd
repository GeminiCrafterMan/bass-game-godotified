extends CharacterBody2D

const W_Type = 9	# This is Wild Gale.
var wait : int
@onready var visuals

func _ready():
	visuals = preload("res://scenes/Objects/Players/Weapons/Special Weps/wild_gale_visuals.tscn").instantiate()
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
	
