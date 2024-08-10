extends CharacterBody2D

var projectile
var buster_timer : int
	
var projectile_scenes = [preload("res://scenes/Objects/Players/Weapons/Bass/buster.tscn")]
	
func _ready():
	$SpawnSound.play()

func _physics_process(delta):
	buster_timer = buster_timer + 1
	
	
	if buster_timer > 17:
		projectile = projectile_scenes[0].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x
		projectile.position.y = position.y
		if scale.x == -1:
			projectile.velocity.x = -240
		else:
			projectile.velocity.x = 240
		buster_timer = 0
	return
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

