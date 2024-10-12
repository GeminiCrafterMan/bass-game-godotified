extends Sprite2D

class_name Telly_Hole

func _process(_delta):
	if $Timer.is_stopped() && GameState.tellies < 6:
		var projectile = preload("res://scenes/objects/enemies/telly.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		GameState.tellies += 1
		$Timer.start(4)
		print("enabled")
