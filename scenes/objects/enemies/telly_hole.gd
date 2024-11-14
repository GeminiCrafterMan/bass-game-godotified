class_name Telly_Hole extends Sprite2D

static var num_tellies: int

func _physics_process(_delta):
	if $Timer.is_stopped() && num_tellies < 6:
		var projectile = preload("res://scenes/objects/enemies/telly.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		projectile.telly_hole = self
		num_tellies += 1
		$Timer.start(4)
		print(num_tellies, " tellies spawned")
