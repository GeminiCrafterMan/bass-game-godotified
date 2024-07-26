extends Node

func _ready():
	var player_scene : PackedScene
	if GlobalVars.character_selected:
		player_scene = load("res://Scenes/Objects/Players/copy_robot.tscn")
	else:
		player_scene = load("res://Scenes/Objects/Players/bass.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.position.x = $StartPosition.position.x
	player.targetpos = $StartPosition.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_camera()
	
func process_camera():
	if (get_tree().get_root().has_node("AirManStage/Player")): # Null check!
		if ($Player.teleporting == false):
			$Camera2D.position = $Player.position
		else:
			$Camera2D.position = $StartPosition.position
		if ($Player.position.x > 2304):
			$Camera2D.limit_bottom = 720
		else:
			$Camera2D.limit_left = 0
			$Camera2D.limit_bottom = 240
		if ($Player.position.x > 2560):
			if ($Player.position.y > 480):
				$Camera2D.limit_right = 5120
