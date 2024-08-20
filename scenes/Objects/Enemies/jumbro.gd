extends Enemy_Template

class_name Jumbro

func _ready():
	Atk_Dmg = 8
	Max_HP = 4
	Cur_HP = 4

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

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv == 0:
		Cur_HP -= Dmg_Vals[weapon.W_Type]
		Cur_Inv = 2
	weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
