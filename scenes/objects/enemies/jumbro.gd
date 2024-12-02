extends Enemy_Template

class_name Jumbro
@onready var projectile

var hops : int

func _ready():
	Atk_Dmg = 4
	Cur_HP = 4

func _physics_process(delta):
	if Cur_HP <= 0:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		if GameState.droptimer < 3:
			projectile = preload("res://scenes/objects/items/pickup.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.dropped = true
		queue_free()
		
	if !is_on_floor():
		velocity += get_gravity() * delta
	else:
		if hops > 3:
			velocity.y =  -80
			hops = 0
		else:
			velocity.y =  -30
			hops += 1
	
	if blown == true:
		position.x += GameState.galeforce*0.015
		
	if Cur_Inv > 0:
		Cur_Inv -= 1
		if Cur_Inv % 2 == 0:
			$Sprite.visible = false
		else:
			$Sprite.visible = true
	else:
		$Sprite.visible = true

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	if Cur_Inv <= 0 or weapon.W_Type == 8 or weapon.W_Type == 11 or weapon.W_Type == 22:
		if Dmg_Vals[weapon.W_Type] == 0:
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
