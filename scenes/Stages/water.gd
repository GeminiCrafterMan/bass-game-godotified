extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(wetboy): # needs to be redefined because damage values
	wetboy.JUMP_VELOCITY = -325.0
	wetboy.PEAK_VELOCITY = -90.0
	wetboy.STOP_VELOCITY = -80.0
	wetboy.JUMP_HEIGHT = 13
	wetboy.FAST_FALL = 200.0
	
func _on_body_exited(wetboy): # needs to be redefined because damage values
	wetboy.JUMP_VELOCITY = -225.0
	wetboy.PEAK_VELOCITY = -90.0
	wetboy.STOP_VELOCITY = -80.0
	wetboy.JUMP_HEIGHT = 13
	wetboy.FAST_FALL = 400.0
