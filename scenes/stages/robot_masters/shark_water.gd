extends Node2D

var timer : int
var freq = 0.025
var amplitude = 0.2
var v = Vector2(0, 25)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $Timer.is_stopped():
		timer += 1

	v.y = (cos(timer * freq) * amplitude)

	position.y += v.y
