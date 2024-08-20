extends CharacterBody2D

class_name Enemy_Template

var Dmg_Vals = [
	1,	# Bass Buster
		1,	# Copy Buster
		2,	# Copy Buster, medium shot
		4,	# Copy Buster, charge shot
		2,	# Scorch Barrier
		0,	# Freeze Frame (if it does damage like Time Stopper on Quick Man)
		0,	# Poison Cloud
		6,	# Fin Shredder
		2,	# Origami Star
		0,	# Wild Gale
		0,	# Rolling Bomb(?)
		0,	# Boomerang Scythe
		2,	# Proto Buster medium shot
		4,	# Proto Buster charged shot
		4,	# Super Arrow
		0,	# Mirror Buster
		2,	# Screw Crusher
		4,	# Ballade Cracker
		0,	# Sakugarne (Physical hit)
		0,	# Sakugarne (Rock)
		3,	# Houshou-geki blast jump
		0,	# Paper Cut slice
		0	# Whatever's next...
]
var Atk_Dmg = 4
var Cur_Inv = 0
var Max_HP = 3
var Cur_HP = 3

func _process(delta):
	if Cur_HP <= 0:
		queue_free()
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			visible = false
		else:
			visible = true
	else:
		visible = true

func _on_hitable_body_entered(weapon):
	if Cur_Inv == 0:
		Cur_HP -= Dmg_Vals[weapon.W_Type]
		Cur_Inv = 2
	weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
