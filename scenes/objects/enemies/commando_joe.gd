extends Enemy_Template

class_name Commando_Joe
@onready var projectile
var timer : int
var attacks : int

func _ready():
	Atk_Dmg = 2
	Max_HP = 12
	Cur_HP = 12
	timer = 200

func _physics_process(_delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		queue_free()
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			visible = false
		else:
			visible = true
	else:
		visible = true
	
	timer = timer -1
	if timer > 300:
		timer = 300
	
	if timer < 0 && $AnimatedSprite2D.animation == "Idle":
		$AnimatedSprite2D.play("SwitchAtk")
		$reflect/ShieldHitbox.set_disabled(true)
		timer = 10

	if timer < 0 && $AnimatedSprite2D.animation == "SwitchAtk":	
		$AnimatedSprite2D.play("Attack")
		$AnimatedSprite2D.set_frame_and_progress(1, 1)
		attacks = 8
		
	if timer < 0 && $AnimatedSprite2D.animation == "Attack" &&  attacks == 0:
		$AnimatedSprite2D.play("SwitchDef")
		timer = 10
	
	if timer < 0 && $AnimatedSprite2D.animation == "Attack" &&  attacks > 0:
		$AnimatedSprite2D.play("Attack")
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		
		projectile = preload("res://scenes/objects/enemies/enemy_bullet1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x - 8
		projectile.position.y = position.y - 6
		projectile.velocity.x = -250
		attacks = attacks - 1
		timer = 24
		if attacks > 0:
			timer = 4
		
	
		
		
	if timer < 0 && $AnimatedSprite2D.animation == "SwitchDef":	
		$AnimatedSprite2D.play("Idle")
		$reflect/ShieldHitbox.set_disabled(false)
		timer = 250


func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0:
		if Dmg_Vals[weapon.W_Type] == 0:
			weapon.reflect()
		else:
			Cur_HP -= Dmg_Vals[weapon.W_Type]
			Cur_Inv = 2
			weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg

func _on_reflect_body_entered(weapon):
	timer = timer + 18
	weapon.reflect()
