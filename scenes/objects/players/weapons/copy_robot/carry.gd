
extends StaticBody2D

var timer : int = -1
var flashtimer : int

@onready var Interval = $Timer


func _ready():
	Interval.start(0.1)

func _physics_process(_delta):
	if Interval.is_stopped():
		timer += 1
		Interval.start(0.8)
		if timer > 0:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.CARRY] -= 1
	
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.CARRY && $AnimatedSprite2D.animation != "explode":
		Interval.start(5)
		GameState.onscreen_sp_bullets -= 1
		$AnimatedSprite2D.play("explode")
		$Shape.disabled = true
		await $AnimatedSprite2D.animation_finished
		queue_free()
		
	
	
	
	if timer > 1:
		flashtimer = (flashtimer + 1)
		if $AnimatedSprite2D.animation != "explode":
			if flashtimer == 3:
				$AnimatedSprite2D.hide()
			if flashtimer == 6:
				$AnimatedSprite2D.show()
				flashtimer = 0
		else:
			$AnimatedSprite2D.show()
	if timer == 3:
		timer = 5
		$AnimatedSprite2D.play("explode")
		GameState.onscreen_sp_bullets -= 1
		$Shape.disabled = true
		Interval.start(5)
		await $AnimatedSprite2D.animation_finished
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_bullets -= 1
	queue_free()
