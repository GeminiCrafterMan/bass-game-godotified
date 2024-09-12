extends Enemy_Template

class_name Sniper_Joe
@onready var projectile
var timer : int
var attacks : int

func _ready():
	Atk_Dmg = 4
	Max_HP = 8
	Cur_HP = 8
	timer = 200

func _process(delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/Objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		print("yeouch!")
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
		
	
	timer = timer -1
	if timer > 300:
		timer = 300
	
	if timer < 0 && $Sprite.animation == "Idle":
		$Sprite.play("SwitchAtk")
		$reflect/ShieldHitbox.set_disabled(true)
		timer = 10

	if timer < 0 && $Sprite.animation == "SwitchAtk":	
		$Sprite.play("Attack")
		$Sprite.set_frame_and_progress(1, 1)
		attacks = 3
		
	if timer < 0 && $Sprite.animation == "Attack" &&  attacks == 0:
		$Sprite.play("SwitchDef")
		timer = 10
	
	if timer < 0 && $Sprite.animation == "Attack" &&  attacks > 0:
		$Sprite.play("Attack")
		$AudioStreamPlayer.play()
		$Sprite.set_frame_and_progress(0, 0)
		
		projectile = preload("res://scenes/Objects/Enemies/enemy_bullet1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x - 8
		projectile.position.y = position.y - 6
		projectile.velocity.x = -250
		attacks = attacks - 1
		timer = 15
		if attacks > 0:
			timer = 25
		
	
		
		
	if timer < 0 && $Sprite.animation == "SwitchDef":	
		$Sprite.play("Idle")
		$reflect/ShieldHitbox.set_disabled(false)
		timer = 250


func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8:
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

func _on_reflect_body_entered(weapon):
	timer = timer + 18
	weapon.reflect()
