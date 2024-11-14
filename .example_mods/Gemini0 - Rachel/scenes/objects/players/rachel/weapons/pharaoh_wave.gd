extends CharacterBody2D

const W_Type = 7	# This is Fin Shredder. G: Um, ackshuwally, it's Pharaoh Wave...

# Okay, so. I'm just going to deal with *functionality* if I keep making these weapons. No sounds until Resonate is fully functioning in the base game.

#func _ready():
#	$SpawnSound.play()
		
func _physics_process(_delta):
	move_and_slide()
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != 7: # I'd use the enum, but I can't unless I make it global, which wouldn't be a good idea.
		GameState.onscreen_sp_bullets = 0
		queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()

func destroy():
	GameState.onscreen_sp_bullets -= 1
	queue_free()

func kill():
	pass

func reflect():
	pass	# not reflectable
