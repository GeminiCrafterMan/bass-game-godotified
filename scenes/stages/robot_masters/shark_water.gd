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
	$CanvasLayer/Shade2.position.y = level + 304

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if GameState.camposy < 300:
		if $Timer.is_stopped():
			timer += 1
			$Timer.start(0.02)

		v.y = (cos(timer * freq) * amplitude)
	
		position.y += v.y
	
	level = position.y + 3
	
	
func _process(_delta):
	if GameState.camposy >= 280:
		$Level.position.y = -900
		$CanvasLayer/Shade2.visible = false
		$CanvasLayer/Shade3.visible = true
		$CanvasLayer/Shade3.position.y = 0
	else:
		if GameState.camposy < 110:	
			$CanvasLayer/Shade2.position.y = level + 189
		else:
			$CanvasLayer/Shade2.position.y = level + 301 - GameState.camposy
		$CanvasLayer/Shade2.visible = true
		$CanvasLayer/Shade3.visible = false
		
	if GameState.camposx >= 5280 && GameState.camposy <= 900:
		$CanvasLayer/Shade3.position.y = 852 - GameState.camposy
