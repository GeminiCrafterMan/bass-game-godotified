extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_camera()
	
func process_camera():
	if (get_tree().get_root().has_node("Mengo/Player")): # Null check!
		$Camera2D.position = $Player.position
		$Camera2D.limit_left = 0
		$Camera2D.limit_bottom = 240
