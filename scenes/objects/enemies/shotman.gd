extends Enemy_Template

class_name ShotMan
@onready var projectile
@onready var timer = $Timer

var attacks : int

func _ready():
	Atk_Dmg = 4
	Cur_HP = 5
	timer = 200
	
	Dmg_Vals = [
		1,	#0  Bass Buster 
		1,	#1  Copy Buster
		2,	#2  Copy Buster, medium shot
		4,	#3  Copy Buster, charge shot
		3,	#4  Scorch Barrier
		0,	#5  Freeze Frame (if it does damage like Time Stopper on Quick Man)
		1,	#6  Poison Cloud
		8,	#7  Fin Shredder
		2,	#8  Origami Star
		8,	#9  Wild Gale
		2,	#10 Rolling Bomb(?)
		3,	#11 Boomerang Scythe
		2,	#12 Proto Buster medium shot
		4,	#13 Proto Buster charged shot
		4,	#14 Super Arrow
		1,	#15 Mirror Buster
		2,	#16 Screw Crusher
		4,	#17 Ballade Cracker
		4,	#18 Sakugarne (Physical hit)
		1,	#19 Sakugarne (Rock)
		3,	#20 Blast jump
		4,	#21 Paper Cut slice
		5,	#22 Charged Boomer Scythe
		0	# Whatever's next...
	]
	if (GameState.player != null): # Null check!
			if get_node(GameState.player).position.x > position.x:
				scale.x = -1
			else:
				scale.x = 1
				
	$Timer.start(0.5)

func _process(_delta):
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
	
	
	if $Sprite.animation == "Idle-1":
		$Timer.start(0.2)
		$Sprite.play("Attack-1")
		attacks = 3
		
	if $Timer.is_stopped() && attacks == 0 && $Sprite.animation == "Attack-1":
		$Sprite.play("Switch-1")
		$Timer.start(1.1)
		attacks = 3
		
	if $Timer.is_stopped() && attacks == 0 && $Sprite.animation == "Attack-2":
		$Sprite.play("Switch-2")
		$Timer.start(1.1)
		attacks = 3
		
	if $Timer.is_stopped() && ($Sprite.animation == "Switch-2" or $Sprite.animation == "Attack-1"):
		$Sprite.play("Attack-1")
		$Sprite.set_frame_and_progress(0, 0)
		$Timer.start(0.45)
		projectile = preload("res://scenes/objects/enemies/enemy_bullet2.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x - (scale.x * 16)
		projectile.position.y = position.y - 6
		projectile.velocity.x = scale.x * -330
		projectile.velocity.y = -120
		attacks -= 1
		
	if $Timer.is_stopped() && ($Sprite.animation == "Switch-1" or $Sprite.animation == "Attack-2"):
		$Sprite.play("Attack-2")
		$Sprite.set_frame_and_progress(0, 0)
		$Timer.start(0.45)
		projectile = preload("res://scenes/objects/enemies/enemy_bullet2.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x - (scale.x * 15)
		projectile.position.y = position.y - 19
		projectile.velocity.x = scale.x * -105
		projectile.velocity.y = -370
		attacks -= 1
	
	
	
	

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22:
		if Dmg_Vals[weapon.W_Type] == 0:
			if weapon.W_Type == 7:
				weapon.destroy()
			else:
				weapon.reflect()
		else:
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			if Cur_HP <= 0 or weapon.W_Type == 7 or weapon.W_Type == 11 or weapon.W_Type == 22:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
