extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = GameState.character_selected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Text.text = "x%02d" % GameState.player_lives
	if GameState.player != null:
		$Sprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
