extends CharacterBody2D

const W_Type = 9	# This is Wild Gale.
@onready var direction

func _ready():
	$SpawnSound.play()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()
	
func _physics_process(_delta):
	if velocity.x < 200 && velocity.x > -200:
		velocity.x *= 2.25
	else:
		velocity.x *= 1.01
	
		$FX2.position.x += 1
		
		if GameState.character_selected == 2:
			$FX.position.y += 0.5
			$FX2.position.y -= 0.5
	
	GameState.galeforce = velocity.x
	
	if move_and_slide() == true:
		destroy()

func destroy():
	pass

func reflect():
	pass
	
func kill():
	pass
	
