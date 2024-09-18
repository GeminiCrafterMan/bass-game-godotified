@tool
extends CharacterBody2D

@export var item_type : int 
@export var item_size : int 

var amount : int
var collected : bool
		
func _ready():
	pass

func _process(delta):
	match item_type:
		0: #HP Item
			match item_size:
				0:
					$AnimatedSprite2D.play("SmHP")
				1:
					$AnimatedSprite2D.play("LgHP")
		1: #WE Item
			match item_size:
				0:
					$AnimatedSprite2D.play("SmWE")
				1:
					$AnimatedSprite2D.play("LgWE")
			
		2: #Bolts
			match item_size:
				0:
					$AnimatedSprite2D.play("SmBT")
				1:
					$AnimatedSprite2D.play("LgBT")
					
		3: #E and W tank
			match item_size:
				0:
					$AnimatedSprite2D.play("ETnk")
				1:
					$AnimatedSprite2D.play("WTnk")
					
		4: #1Up and S tank
			match item_size:
				0:
					$AnimatedSprite2D.play("1Up")
					if not Engine.is_editor_hint():
						$AnimatedSprite2D.set_frame_and_progress(GameState.character_selected, 0)
				1:
					$AnimatedSprite2D.play("STnk")
								
	
		

	if not Engine.is_editor_hint():
		if $Timer.is_stopped() && collected == true:
			queue_free()
			
		if GameState.player != null:
			$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))

func _on_touch_body_entered(body):
	if body.is_in_group("player"):
		collected = true
		position.y = -2000
		position.x = -2000
		$Timer.start(1)
	
			
		match item_size:
			0:
				amount = 2
				if item_type == 2:
					amount = 5
			1:
				amount = 10
		
		match item_type:
			0: # HP
				GameState.current_hp += amount
			1: # WE
				GameState.weapon_energy[GameState.current_weapon] += amount
			2: # BOLTS
				$BoltSound.play()
				GameState.bolts += amount
				
			3: # Tanks
				$ItemSound.play()
				match item_size:
					0:
						GameState.ETanks += 1
					1:
						GameState.WTanks += 1
				
			4: # 1Up+S
				$ItemSound.play()
				match item_size:
					0:
						GameState.player_lives += 1
					1:
						GameState.STanks += 1
		
		
		
		
		
