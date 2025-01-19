extends Enemy_Template

@onready var projectile

const SPEED = 20.0
const REACTIONTIME = 40
var state : int = 0
var dir : float

func _ready():
	basedmg()
	if (GameState.player == null) or (GameState.player.position.x < position.x):
		velocity.x = -SPEED
	else:
		scale.x *= -1
		velocity.x = SPEED

func _physics_process(_delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		print("yeouch!")
		if GameState.droptimer < 3:
			projectile = preload("res://scenes/objects/items/pickup.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.dropped = true
		queue_free()
		
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			$Sprite.visible = false
			print("disappear!")
		
		else:
			$Sprite.visible = true
			print("appear!")
	else:
		$Sprite.visible = true
		
	if blown == false:
		if state == 0:
			if GameState.player != null:
				if position.x < GameState.playerposx + 50 && position.x > GameState.playerposx - 50:
					$Sprite.play("see")
					state = 1
		if state > 1 && state < REACTIONTIME:
			state += 1
		if state == REACTIONTIME:
			if GameState.player != null:
				$Sprite.play("charge")
				look_at(GameState.player.position)
				velocity=Vector2(SPEED,0).rotated(dir)
				state += 1
				
			
				
		move_and_slide()
