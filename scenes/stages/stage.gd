class_name Stage
extends Node2D

@onready var player # kind of the same thing as GameState.player, but not really? This one's used to *instantiate* the player.
@onready var splash  

var refilltimer : int

func _ready():
	var hud = preload("res://scenes/hud.tscn").instantiate()
	add_child(hud)
	GameState.player = null
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
	player.position.y = $StartPosition.position.y - 230
	player.targetpos = $StartPosition.position.y
	await player.teleported
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_camera()
	process_refills()
	process_drops()
	
	
func process_drops():
	GameState.droptimer += 1
	if GameState.droptimer > 8:
		GameState.droptimer = 0
		
	GameState.itemtimer -= 1
	if GameState.itemtimer <= 0:
		GameState.itemtimer = 15
	
func process_camera():
	if (player != null): # Null check!
		if (GameState.current_hp > 0):
			if (player.currentState != player.STATES.TELEPORT):
				$Camera2D.position = player.position
			else:
				$Camera2D.position = $StartPosition.position
	
func process_refills():
	if (player != null): # Null check!
		if (GameState.ammoamt):
			if refilltimer == 0:
				if GameState.weapon_energy[GameState.current_weapon] < 28:
					refilltimer = 3
					GameState.weapon_energy[GameState.current_weapon] += 1
					GameState.ammoamt -= 1
				else:
					GameState.ammoamt = 0
			else:
				refilltimer -= 1
			
		if (GameState.healamt):
			if refilltimer == 0:
				if GameState.current_hp < 28:
					refilltimer = 3
					GameState.current_hp += 1
					GameState.healamt -= 1
				else:
					GameState.healamt = 0
			else:
				refilltimer -= 1
		
			
				


func _on_water_body_exited(dry):
	
	if dry.is_in_group("player"):
		dry.JUMP_VELOCITY = -225.0
		dry.PEAK_VELOCITY = -90.0	
		dry.STOP_VELOCITY = -80.0
		dry.JUMP_HEIGHT = 13
		dry.FAST_FALL = 400.0
		dry.in_water = false
		
	if dry.is_in_group("scorch"):
		dry.wet = false


func _on_water_body_entered(wet):
	
	if wet.is_in_group("player"):
		wet.JUMP_VELOCITY = -285.0
		wet.PEAK_VELOCITY = -110.0	
		wet.STOP_VELOCITY = -110.0
		wet.JUMP_HEIGHT = 23
		wet.FAST_FALL = 200.0
		wet.in_water = true
		
	if wet.is_in_group("scorch"):
		wet.wet = true
		
	

func _on_splash_zone_body_entered(body):
	if body.is_in_group("splash"):
		splash = preload("res://scenes/objects/splash.tscn").instantiate()
		add_child(splash)
		splash.position.x = body.position.x
		splash.position.y = body.position.y + body.velocity.y * 0.0005
		#wet.is_wet = false


func _on_ice_body_entered(body):
	if body.is_in_group("player"):
		body.on_ice = true
		print("YeICE")


func _on_ice_body_exited(body):
	if body.is_in_group("player"):
		body.on_ice = false
		print("NoICE")
