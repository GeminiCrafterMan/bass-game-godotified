extends CharacterBody2D

const W_Type = 6	# This is Poison Cloud.

var time : int

func _ready():
	$SpawnSound.play()
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Spawn")
		
func _physics_process(_delta):
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
	
	
	if GameState.current_weapon != 3:
		queue_free()	
	
	time = time + 1
	if $AnimatedSprite2D.animation == "Spawn":
		if time > 25:
			$AnimatedSprite2D.play("Loop")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func kill():
	pass

func reflect():
	pass	# not reflectable