extends CharacterBody2D

class_name Enemy_Template

var Dmg_Vals = [
		1,	#0  Bass Buster 
		1,	#1  Copy Buster
		2,	#2  Copy Buster, medium shot
		4,	#3  Copy Buster, charge shot
		2,	#4  Scorch Barrier
		0,	#5  Freeze Frame (if it does damage like Time Stopper on Quick Man)
		1,	#6  Poison Cloud
		6,	#7  Fin Shredder
		2,	#8  Origami Star
		10,	#9  Wild Gale
		2,	#10 Rolling Bomb
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
		4,	#23 CR Fin Shredder
		9,	#24 CR Double Fin Shredder
		0	# Whatever's next...
]
var Atk_Dmg = 4
var Cur_Inv = 0
var Max_HP = 3
var Cur_HP = 3
var blown : bool = false

func _physics_process(_delta):
	if Cur_HP <= 0:
		queue_free()
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			$Sprite.visible = false
		else:
			$Sprite.visible = true
	else:
		visible = true

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22:
		if Dmg_Vals[weapon.W_Type] == 0:
			if weapon.W_Type == 7:
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
			
			if Cur_HP <= 0 or weapon.W_Type == 7 or weapon.W_Type == 11 or weapon.W_Type == 22:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
