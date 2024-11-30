extends Enemy_Template

class_name Gabyoall
@onready var projectile
var direction : int
var stun : int

func _ready():
	direction = 1
	Atk_Dmg = 4
	Cur_HP = 2
	
	
	Dmg_Vals = [
		1,	#0  Bass Buster 
		1,	#1  Copy Buster
		1,	#2  Copy Buster, medium shot
		1,	#3  Copy Buster, charge shot
		1,	#4  Scorch Barrier
		0,	#5  Freeze Frame (if it does damage like Time Stopper on Quick Man)
		1,	#6  Poison Cloud
		2,	#7  Fin Shredder
		1,	#8  Origami Star
		2,	#9  Wild Gale
		1,	#10 Rolling Bomb(?)
		1,	#11 Boomerang Scythe
		1,	#12 Proto Buster medium shot
		2,	#13 Proto Buster charged shot
		2,	#14 Super Arrow
		1,	#15 Mirror Buster
		1,	#16 Screw Crusher
		1,	#17 Ballade Cracker
		2,	#18 Sakugarne (Physical hit)
		1,	#19 Sakugarne (Rock)
		1,	#20 Blast jump
		1,	#21 Paper Cut slice
		1,	#22 Charged Boomer Scythe
		2,	#23 CR Fin Shredder
		2,	#24 CR Double Fin Shredder
		0	# Whatever's next...
]

func _physics_process(_delta):
	if blown == false:
		if $Timer.is_stopped() and position != null:
			if stun < 1:
				position.x += direction * 1
				if $Sprite.animation != "Slow" or !$Sprite.is_playing():
					$Sprite.play("Slow")
			else:
				if $Sprite.animation != "Slow":
					$Sprite.play("Slow")
				$Sprite.stop()
				if !$LeftFloorCheck.is_colliding() && !$RightFloorCheck.is_colliding():
					position.y += 3
			stun -= 1
			if GameState.player != null:
				if (position.y > GameState.player.position.y - 10) and (position.y < GameState.player.position.y + 15):
					$Timer.start(0.002)
					if stun < 1:
						position.x += direction * 2
						if $Sprite.animation != "Fast" or !$Sprite.is_playing():
							$Sprite.play("Fast")
							$Sprite.set_frame_and_progress(0,0)
				else:
					if stun > 1:
						$Timer.start(0.01)
					else:
						$Timer.start(0.03)
			else:
						$Timer.start(0.03)
						
		if $RightDirCheck.is_colliding() && direction == 1:
			direction = -1
		
		if $LeftDirCheck.is_colliding() && direction == -1:
			direction = 1
		
		if !$RightFloorCheck.is_colliding() && $LeftFloorCheck.is_colliding() && direction == 1:
			direction = -1
		
		if !$LeftFloorCheck.is_colliding() && $RightFloorCheck.is_colliding() && direction == -1:
			direction = 1
			
		if !$LeftFloorCheck.is_colliding() && !$RightFloorCheck.is_colliding():
			stun = 35
		
	if Cur_HP <= 0:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		queue_free()
		
	if blown == true:
		position.x += GameState.galeforce*0.01
	
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
	
func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22:
		if Dmg_Vals[weapon.W_Type] == 0:
			weapon.reflect()
		
		if Dmg_Vals[weapon.W_Type] == 1:
			weapon.reflect()
			stun = 150
		
		if Dmg_Vals[weapon.W_Type] == 2:
			weapon.kill()
			Cur_HP = 0
			
		if weapon.W_Type == 9:
			blown = true
			Cur_HP = 999
			$hitable.queue_free()
			$hurt.queue_free()
			$Collision.queue_free()
			
	if weapon.is_in_group("scorch"):
		if GameState.character_selected != 2:
			weapon.durability -= 3
		else:
			weapon.durability -= 3
			

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
