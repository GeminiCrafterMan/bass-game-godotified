@tool
extends CharacterBody2D

@export var item_type : int 
@export var item_size : int 

var amount : int
var collected : bool
@export var dropped : bool = true
		
func _ready():
	if not Engine.is_editor_hint():
		if dropped == true:
			if GameState.itemtimer >= 0 && GameState.itemtimer <= 2:
				item_type = 0
					
			if GameState.itemtimer >= 3 && GameState.itemtimer <= 5:
				item_type = 1
				
			if GameState.itemtimer >= 6 && GameState.itemtimer <= 8:
				item_type = 2
			
			if GameState.itemtimer >= 9 && GameState.itemtimer <= 10:
				item_type = 4
					
			if GameState.itemtimer == 2 or GameState.itemtimer == 5 or GameState.itemtimer == 8:
				item_size = 1
			
			$Timer.start(8)
			
			velocity.y = -45
			
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
					$AnimatedSprite2D.hide()
					$Sprite2D.texture = load(GameState.lifeIcons[GameState.character_selected])
					$Sprite2D.show()
				1:
					$AnimatedSprite2D.play("STnk")

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if $Timer.is_stopped() && collected == true:
			queue_free()
				
		if GameState.player != null:
			$AnimatedSprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("Sprite2D").material.get_shader_parameter("palette"))
			$Sprite2D.material.set_shader_parameter("palette", get_node(GameState.player).get_node("Sprite2D").material.get_shader_parameter("palette"))

func _on_touch_body_entered(body):
	if body.is_in_group("player"):
		collected = true
		position.y = -25000
		position.x = -25000
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
				GameState.healamt += amount
			1: # WE
				GameState.ammoamt += amount
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

# G: Needs gravity!! I forgot how to implement it and I'm kinda just cleaning up for the alpha test.
#func _physics_process(delta: float) -> void:
#	move_and_slide()
