class_name Stage
extends Node2D

@onready var player # kind of the same thing as GameState.player, but not really? This one's used to *instantiate* the player.

func _ready():
	$Camera2D.position = $StartPosition.position
	await Fade.fade_in().finished
	$Music.play()
	var player_scene : PackedScene = load(
		GameState.characters[
			GameState.character_selected
		]
	)
	player = player_scene.instantiate()
	add_child(player)
	player.position.x = $StartPosition.position.x
	player.targetpos = $StartPosition.position.y
	await player.teleported
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_camera()
	
func process_camera():
	if (player): # Null check!
		if (player.teleporting == false):
			$Camera2D.position = player.position
		else:
			$Camera2D.position = $StartPosition.position
