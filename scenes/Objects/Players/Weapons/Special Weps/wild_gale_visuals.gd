extends CanvasLayer

var wait : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.character_selected == 0:
		$AnimatedSprite2D.play("Bass")
	else:
		$AnimatedSprite2D.play("Copy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wait > 30:
		queue_free()
	wait = wait + 1
