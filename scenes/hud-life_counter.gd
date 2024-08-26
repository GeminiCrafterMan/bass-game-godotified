extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = GameState.character_selected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Text.text = "x%02d" % GameState.player_lives
