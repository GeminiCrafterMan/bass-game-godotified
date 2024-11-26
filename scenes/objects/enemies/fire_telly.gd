extends Enemy_Template

class_name Fire_Telly

var currentState : int = 0

func _physics_process(delta: float) -> void:
	health_check()
	match currentState:
		0: # Initialize
			if GameState.player:
				velocity.x = -40
				if GameState.player.position.x > position.x:
					velocity.x = -velocity.x
					scale.x = -1
				currentState = 1
		1: # Move and check for player
			$Sprite.play("default")
			move_and_slide()
			if (abs(abs(GameState.player.position.x) - abs(position.x)) <= 100) and $Timer.is_stopped():
				currentState = 2
		2: # Shoot, then reset to 1
			$Sprite.play("drop")
			await $Sprite.animation_finished
			# drop projectile, add later
			currentState = 1
			$Timer.start()
		
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
			if Cur_HP <= 0 or weapon.W_Type == 7 or weapon.W_Type == 11 or weapon.W_Type == 22 or weapon.W_Type == 23 or weapon.W_Type == 24:
				weapon.kill()
			else:
				weapon.destroy()

func _on_hurt_body_entered(body):
	body.DmgQueue = Atk_Dmg


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func health_check():
	if Cur_HP <= 0:
		var projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
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
