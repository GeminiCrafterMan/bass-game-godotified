extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.player != null:
		if GameState.playerposy >= 250:
			$ColorRect.color.a -= 0.05
