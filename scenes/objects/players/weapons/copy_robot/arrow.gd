
extends CharacterBody2D

const W_Type = 14	# This is Copy Robot's Super Arrow.

var timer : int
var flashtimer : int

func _ready():
	$SpawnSound.play()

func _physics_process(_delta):
	if GameState.player != null:
			$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("Sprite2D").material.get_shader_parameter("palette"))

	
	if GameState.current_weapon != GameState.WEAPONS.ARROW:
		GameState.onscreen_sp_bullets -= 1
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()
	
	if move_and_slide() == true && $AnimatedSprite2D.animation == "move":
		$AnimatedSprite2D.play("stick")
		$Timer.queue_free()
		timer = 0
		velocity.x = 0
		
	timer = (timer + 1)
	if $AnimatedSprite2D.animation != "stick":
		if timer == 100:
			$AnimatedSprite2D.animation = "move"
			$Timer.start()
			if velocity.x < 0:	# find a way to fix this for shooting left?
				velocity.x = -50
			else:
				velocity.x = 50
		if timer > 100 && velocity.x > -300 && velocity.x < 300:
				velocity.x = velocity.x * 1.03
	
	if timer > 300 && $AnimatedSprite2D.animation == "stick":
		flashtimer = (flashtimer + 1)
		if $AnimatedSprite2D.animation != "explode":
			if flashtimer == 3:
				$AnimatedSprite2D.hide()
			if flashtimer == 6:
				$AnimatedSprite2D.show()
				flashtimer = 0
		else:
			$AnimatedSprite2D.show()
	if timer == 400 && $AnimatedSprite2D.animation == "stick":
		GameState.onscreen_sp_bullets -= 1
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()

func destroy():
	velocity.x = 0
	velocity.y = 0
	GameState.onscreen_sp_bullets -= 1
	$AnimatedSprite2D.play("explode")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func kill():
	pass

func reflect():
	$ReflectSound.play()
	velocity.x = -velocity.x
	velocity.y = -180

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets = 0
	queue_free()


func _on_timer_timeout() -> void:
	if GameState.infinite_ammo == false:
		GameState.weapon_energy[GameState.WEAPONS.ARROW] -= 1
	$Timer.start()
