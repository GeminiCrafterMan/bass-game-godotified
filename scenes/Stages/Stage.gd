class_name Stage
extends Node2D

@onready var player # kind of the same thing as GameState.player, but not really? This one's used to *instantiate* the player.
@onready var splash  

func _ready():
	$StartPosition/Sprite2D.queue_free()	# just delete the sprite2d instead of making it invisible. why have it stick around?
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
	player.position.y = $StartPosition.position.y -1000
	await player.teleported
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_camera()
	
func process_camera():
	if (player): # Null check!
		if (player.currentState != player.STATES.TELEPORT):
			$Camera2D.position = player.position
		else:
			$Camera2D.position = $StartPosition.position



func _on_water_body_exited(wet):
	splash = preload("res://scenes/Objects/splash.tscn").instantiate()
	add_child(splash)
	splash.position.x = wet.position.x
	splash.position.y = wet.position.y + 21
	
	if wet.is_in_group("player"):
		wet.JUMP_VELOCITY = -225.0
		wet.PEAK_VELOCITY = -90.0	
		wet.STOP_VELOCITY = -80.0
		wet.JUMP_HEIGHT = 13
		wet.FAST_FALL = 400.0

func _on_water_body_entered(wet):
	splash = preload("res://scenes/Objects/splash.tscn").instantiate()
	add_child(splash)
	splash.position.x = wet.position.x
	splash.position.y = wet.position.y + 10
	
	if wet.is_in_group("player"):
		wet.JUMP_VELOCITY = -285.0
		wet.PEAK_VELOCITY = -110.0	
		wet.STOP_VELOCITY = -110.0
		wet.JUMP_HEIGHT = 23
		wet.FAST_FALL = 200.0
