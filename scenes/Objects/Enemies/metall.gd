extends Enemy_Template

class_name Metall
@onready var projectile
var timer : int
var attacks : int


func _ready():
	Atk_Dmg = 2
	Max_HP = 8
	Cur_HP = 8
	timer = 200

func _process(_delta):
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
	if Cur_Inv <= 0 or weapon.W_Type == 8:
		if Dmg_Vals[weapon.W_Type] == 0:
			weapon.reflect()
		else:
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg

func _on_reflect_body_entered(weapon):
	weapon.reflect()
