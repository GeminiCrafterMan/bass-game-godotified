extends Enemy_Template

class_name Sniper_Joe

func _ready():
	# So, Godot is weird. We have to define our vars *here*.
	var Dmg_Vals = [
		1,	# Bass Buster
		1,	# Copy Buster
		2,	# Copy Buster, medium shot
		3,	# Copy Buster, charge shot
		0,	# Scorch Barrier
		0,	# Freeze Frame (if it does damage like Time Stopper on Quick Man)
		0,	# Poison Cloud
		0,	# Fin Shredder
		0,	# Origami Star
		0,	# Gale Force(?)
		0,	# Rolling Bomb(?)
		0,	# Boomerang Scythe
		2,	# Proto Buster medium shot
		4,	# Proto Buster charged shot
		0,	# Super Arrow
		0,	# Mirror Buster
		0,	# Screw Crusher
		0,	# Ballade Cracker
		0,	# Sakugarne (Physical hit)
		0,	# Sakugarne (Rock)
		0,	# Houshou-geki blast jump
		0,	# Paper Cut slice
		0	# Whatever's next...
	]
	Atk_Dmg = 8
	Max_HP = 8
	Cur_HP = 8

func _process(delta):
	if Cur_HP < 0:
		queue_free()
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			visible = false
		else:
			visible = true
	else:
		visible = true

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv == 0:
		Cur_HP -= Dmg_Vals[weapon.W_Type]
		Cur_Inv = 2
	weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg

func _on_reflect_body_entered(weapon):
	weapon.reflect()
