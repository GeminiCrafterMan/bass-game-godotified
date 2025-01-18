extends Node2D

var timer : int
var freq = 0.03
var amplitude = 0.15
var v = Vector2(0, 25)
var level

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.camposy = 0
	GameState.camposx = 0
	level = position.y + 3
	$CanvasLayer/Shade.position.y = level + 304
	
# Called every frame. '_delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if GameState.camposx > 4000:
		level = 440
		$WaterLayer.autoscroll.x = 30
	if GameState.camposx > 5500:
		level = 660
	
	
func _process(_delta):
		$CanvasLayer/Shade.position.y = level + 1600 - GameState.camposy
		$WaterLayer/Waves.position.y = level - 192
