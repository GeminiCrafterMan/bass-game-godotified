extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_camera()
	
func process_camera():
	if (get_tree().get_root().has_node("AirManStage/Player")): # Null check!
		$Camera2D.position = $Player.position
		if ($Player.position.x > 2304):
			$Camera2D.limit_bottom = 720
		else:
			$Camera2D.limit_left = 0
			$Camera2D.limit_bottom = 240
		if ($Player.position.x > 2560):
			if ($Player.position.y > 480):
				$Camera2D.limit_right = 5120
