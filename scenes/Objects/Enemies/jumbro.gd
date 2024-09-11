extends Enemy_Template

class_name Jumbro
@onready var projectile

func _ready():
	Atk_Dmg = 8
	Max_HP = 4
	Cur_HP = 4

func _process(delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/Objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		queue_free()
	
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			$Sprite.visible = false
		else:
			$Sprite.visible = true
	else:
		$Sprite.visible = true

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 2:
		if Dmg_Vals[weapon.W_Type] == 0:
			weapon.reflect()
		else:
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			if Cur_HP == 0:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg
