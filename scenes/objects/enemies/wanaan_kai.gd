extends Enemy_Template

class_name Wanaan_Kai
@onready var projectile
@onready var timer = $Timer

var range : int = 15
var attacking : bool

func _ready():
	Atk_Dmg = 4
	Cur_HP = 5
	
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
		6,	#23 CR Fin Shredder
		9,	#24 CR Double Fin Shredder
		0	# Whatever's next...
	]

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
		if GameState.player != null:
			if (GameState.player.position.x > position.x - range) and (GameState.player.position.x < position.x + range) and $Sprite.animation == "ready" and (GameState.player.position.y > position.y - range*0.5) and (GameState.player.position.y < position.y + range*0.5):
				$Sprite.play("attack")
				await $Sprite.animation_finished;
				$hitable/IdleHitbox.set_disabled(true)
				$hitable/AttackHitbox.set_disabled(false)
				$hurt/Hurtbox.set_disabled(false)
				$Sprite.play("finished")
		
	if blown == true:
		position.x += GameState.galeforce*0.015
		

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22 or weapon.W_Type == 23 or weapon.W_Type == 24:
		if Dmg_Vals[weapon.W_Type] == 0:
			if weapon.W_Type == 7 or weapon.W_Type == 23 or weapon.W_Type == 24:
				weapon.destroy()
			else:
				weapon.reflect()
		else:
			if weapon.is_in_group("scorch"):
				if GameState.character_selected != 2:
					weapon.durability -= 1
				else:
					weapon.durability -= 2
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			if Cur_HP <= 0 and weapon.W_Type == 9:
				Cur_HP = 999
				blown = true
				$hitable.queue_free()
				$hurt.queue_free()
				$Collision.queue_free()
			if Cur_HP <= 0 or weapon.W_Type == 7 or weapon.W_Type == 11 or weapon.W_Type == 22 or weapon.W_Type == 23 or weapon.W_Type == 24:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_trigger_body_entered(body):
	pass
