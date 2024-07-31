class_name Stage
extends Node2D

@onready var player

func _ready():
	var player_scene : PackedScene = load(
		GlobalVars.characters[
			GlobalVars.character_selected
		]
	)
	player = player_scene.instantiate()
	add_child(player)
	player.position.x = $StartPosition.position.x
	player.targetpos = $StartPosition.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_camera()
	
func process_camera():
	if (is_instance_valid(player)): # Null check!
		if (player.teleporting == false):
			$Camera2D.position = player.position
		else:
			$Camera2D.position = $StartPosition.position