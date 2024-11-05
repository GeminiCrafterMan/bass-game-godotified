@tool
extends CharacterBody2D

## An item, sometimes dropped from an enemy or placed in a level.
class_name Item

## Defines what type of item this node is.
@export var item_type : int
## Defines what size of item this node is.
@export var item_size : int 

## How much this item gives.
var amount : int
## Whether this item has been collected or not.
var collected : bool
## Whether this item was dropped by an enemy. Implies [code]has_gravity[/code] as well.
@export var dropped : bool = true
## Whether this item has gravity or not.
@export var has_gravity : bool = false

func _ready():
	if not Engine.is_editor_hint():
		if dropped == true:
			has_gravity = true
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
					if not Engine.is_editor_hint():
						$CollisionShape2D.scale.x = 2
						$CollisionShape2D.scale.y = 2
		1: #WE Item
			match item_size:
				0:
					$AnimatedSprite2D.play("SmWE")
				1:
					$AnimatedSprite2D.play("LgWE")
					if not Engine.is_editor_hint():
						$CollisionShape2D.scale.x = 2
						$CollisionShape2D.scale.y = 1.8
			
		2: #Bolts
			match item_size:
				0:
					$AnimatedSprite2D.play("SmBT")
				1:
					$AnimatedSprite2D.play("LgBT")
					if not Engine.is_editor_hint():
						$CollisionShape2D.scale.x = 2
						$CollisionShape2D.scale.y = 1.8
					
		3: #E and W tank
			if not Engine.is_editor_hint():
				$CollisionShape2D.scale.x = 2
				$CollisionShape2D.scale.y = 2
			match item_size:
				0:
					$AnimatedSprite2D.play("ETnk")
				1:
					$AnimatedSprite2D.play("WTnk")
					
		4: #1Up and S tank
			if not Engine.is_editor_hint():
				$CollisionShape2D.scale.x = 2
				$CollisionShape2D.scale.y = 2
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

func _physics_process(delta: float) -> void:
	if has_gravity == true:
		if not Engine.is_editor_hint():
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta
			move_and_slide()
