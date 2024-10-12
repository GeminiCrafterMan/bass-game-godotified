extends Enemy_Template

class_name Telly_Hole
@onready var projectile

func _ready():
	pass

func _process(_delta):
	
	if $Timer.is_stopped() && GameState.tellies < 6:
		projectile = preload("res://scenes/objects/enemies/telly.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		GameState.tellies += 1
		$Timer.start(4)
