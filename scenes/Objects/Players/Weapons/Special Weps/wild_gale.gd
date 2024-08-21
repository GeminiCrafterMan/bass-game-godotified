extends CharacterBody2D

const W_Type = 9	# This is Wild Gale.
var wait : int

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")
		
func _physics_process(delta):
	if wait > 30:
		queue_free()
	wait = wait + 1

func destroy():
	pass

func reflect():
	pass
	
