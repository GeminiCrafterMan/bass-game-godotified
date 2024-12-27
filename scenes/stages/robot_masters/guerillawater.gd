extends Node2D

var timer : int
var freq = 0.03
var amplitude = 0.15
var v = Vector2(0, 25)
var level

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.camposy = 0
	level = position.y + 3
	$CanvasLayer/Shade.position.y = level + 304

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if GameState.camposy < 1600:
		if $Timer.is_stopped():
			timer += 1
			$Timer.start(0.02)

		v.y = (cos(timer * freq) * amplitude)
	
		position.y += v.y
	
	level = position.y + 3
	
	
func _process(delta):
		$CanvasLayer/Shade.position.y = level + 1600 - GameState.camposy
