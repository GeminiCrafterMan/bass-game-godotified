extends Node2D

var timer : int
var freq = 0.025
var amplitude = 0.2
var v = Vector2(0, 25)
var level

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.playerposy = 0
	level = position.y
	$CanvasLayer/Shade2.position.y = level + 304


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $Timer.is_stopped():
		timer += 1

	v.y = (cos(timer * freq) * amplitude)

	position.y += v.y
	
	level = position.y
	
	
	
	if GameState.playerposy >= 280:
		$CanvasLayer/Shade2.position.y = 0
		$CanvasLayer/Shade2.color.a = 2
	elif GameState.playerstate != 1:
		$CanvasLayer/Shade2.position.y = level + 304 - GameState.playerposy
		$CanvasLayer/Shade2.color.a = 94
	else:
		$CanvasLayer/Shade2.position.y = level + 160
