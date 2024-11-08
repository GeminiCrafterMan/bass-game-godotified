class_name Stage
extends Node2D

@onready var player # kind of the same thing as GameState.player, but not really? This one's used to *instantiate* the player.
@onready var splash  

@export var C1screenmode : int
@export var C1scrollX1 : int
@export var C1scrollX2 : int
@export var C1scrollY1 : int
@export var C1scrollY2 : int

@export var C2screenmode : int
@export var C2scrollX1 : int
@export var C2scrollX2 : int
@export var C2scrollY1 : int
@export var C2scrollY2 : int

@export var C3screenmode : int
@export var C3scrollX1 : int
@export var C3scrollX2 : int
@export var C3scrollY1 : int
@export var C3scrollY2 : int

var refilltimer : int

var voffset : int = 16

func _ready():
	var hud = preload("res://scenes/hud.tscn").instantiate()
	add_child(hud)
	GameState.player = null
	
	$StartPosition/Sprite2D.queue_free()	# just delete the sprite2d instead of making it invisible. why have it stick around?


	$Camera2D.position = $StartPosition.position
	GameState.scrollX1 = C1scrollX1
	GameState.scrollX2 = C1scrollX2
	GameState.scrollY1 = C1scrollY1
	GameState.scrollY2 = C1scrollY2
	GameState.screenmode = C1screenmode
		
	
		
	await Fade.fade_in().finished
	$Music.play()
	$HUD/READY._do_ready_thing()
	await $HUD/READY.animation_finished
	var player_scene : PackedScene = load(
		GameState.characters[
			GameState.character_selected
		]
	)
	player = player_scene.instantiate()
	add_child(player)
	if player.has_method("teleport"):
		player.position.x = $StartPosition.position.x
		player.position.y = $StartPosition.position.y - 230
		player.targetpos = $StartPosition.position.y
		await player.teleported
	else:
		player.position = $StartPosition.position
	if player.has_method("play_start_sound"): # G: Finally, a foolproof method to do this...
		player.play_start_sound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_camera()
	process_refills()
	process_drops()
	
func _physics_process(delta):
	if GameState.screentransiton != 0:
		process_screentrans()
	
func process_drops():
	GameState.droptimer += 1
	if GameState.droptimer > 8:
		GameState.droptimer = 0
		
	GameState.itemtimer -= 1
	if GameState.itemtimer <= 0:
		GameState.itemtimer = 15
	
func process_camera():
	
	if GameState.transdir == 1 && ($Camera2D.position.x < (384*GameState.scrollX1) + 192):
		$Camera2D.position.x += 8
		
	if GameState.transdir == 2 && ($Camera2D.position.y < (216*GameState.scrollY1)+108 + voffset):
		$Camera2D.position.y += 8
	
	if GameState.transdir == 3 && ($Camera2D.position.x > (384*GameState.scrollX2) - 192):
		$Camera2D.position.x -= 8
		
	if GameState.transdir == 4 && ($Camera2D.position.y > (216*GameState.scrollY2)-108 + voffset):
		$Camera2D.position.y -= 8
		
	if ($Camera2D.position.x < (384*GameState.scrollX1) + 192) and ($Camera2D.position.y < (216*GameState.scrollY1)+108 + voffset) and ($Camera2D.position.x > (384*GameState.scrollX2) - 192) and ($Camera2D.position.y > (216*GameState.scrollY2)-108 + voffset):
		GameState.transdir = 0
	
	if (player != null): # Null check!
		if (GameState.current_hp > 0):
			if (player.currentState != player.STATES.TELEPORT):
				
				
				
				if GameState.screenmode == 0 or GameState.screenmode == 1:
					if player.position.x > (384*GameState.scrollX1) + 192 and player.position.x < (384*GameState.scrollX2) - 192:
						$Camera2D.position.x = player.position.x
						
					
						
				if GameState.screenmode == 1 or GameState.screenmode == 3:
					if GameState.transdir == 0:
						$Camera2D.position.y = (216*GameState.scrollY1) + 108  + voffset
							
						
				if GameState.screenmode == 0 or GameState.screenmode == 2:
					
					
					if (player.position.y > (216*GameState.scrollY1) + 108 + voffset):
						if (player.position.y > $Camera2D.position.y) and player.velocity.y == 0:
							$Camera2D.position.y += 3
						
						if (player.position.y > $Camera2D.position.y + 20 ):
							$Camera2D.position.y = player.position.y - 20
					
					
					if (player.position.y < (216*GameState.scrollY2) - 108 + voffset):
						if (player.position.y < $Camera2D.position.y) and player.velocity.y == 0:
							$Camera2D.position.y -= 3
							
						if (player.position.y < $Camera2D.position.y - 20 ):
							$Camera2D.position.y = player.position.y + 20
						
					if GameState.screenmode == 2:
						$Camera2D.position.x = (384*GameState.scrollX1)+192 
						
					#if GameState.transdir == 0: 
					if $Camera2D.position.y < (216*GameState.scrollY1) + 108  + voffset:
						$Camera2D.position.y = (216*GameState.scrollY1) + 108  + voffset
					if $Camera2D.position.y > (216*GameState.scrollY2) - 108  + voffset:
						$Camera2D.position.y = (216*GameState.scrollY2) - 108  + voffset
	
	
	else:
	
		if $Camera2D.position.y < (216*GameState.scrollY1) + 108  + voffset:
			$Camera2D.position.y = (216*GameState.scrollY1) + 108  + voffset
		if $Camera2D.position.y > (216*GameState.scrollY2) - 108  + voffset:
			$Camera2D.position.y = (216*GameState.scrollY2) - 108  + voffset
		
		if $Camera2D.position.x < (384*GameState.scrollX1) + 192:
			$Camera2D.position.x = (384*GameState.scrollX1) + 192
		if $Camera2D.position.x > (384*GameState.scrollX2) - 192:
			$Camera2D.position.x = (384*GameState.scrollX2) - 192
	
	
	
	
	GameState.camposx = $Camera2D.position.x
	GameState.camposy = $Camera2D.position.y
	
	
func process_screentrans():
	if GameState.screentransiton == 1:
		$TransTimer.start(0.75) 
		GameState.screentransiton = 2
	
	if GameState.screentransiton == 2 && $TransTimer.is_stopped():
		GameState.screentransiton = 3
	
	if GameState.screentransiton == 3:
		if $Camera2D.position.x != (384*GameState.scrollY1) + 192 && $Camera2D.position.y != (216*GameState.scrollY1) + 108  + voffset:
			if $Camera2D.position.x > (384*GameState.dest_X) + 192:
				$Camera2D.position.x += 4
			if $Camera2D.position.x < (384*GameState.dest_X) + 192:
				$Camera2D.position.x -= 4
				
			if $Camera2D.position.y > (216*GameState.dest_Y) + 108  + voffset:
				$Camera2D.position.y += 4
			if $Camera2D.position.y < (216*GameState.dest_Y) + 108  + voffset:
				$Camera2D.position.y -= 4
			
			
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
