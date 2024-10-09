extends MaestroPlayer

class_name CopyRobotPlayer

func _init() -> void:
	attack_timer = $FireDelay
	
	weapon_palette = [
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/copy_robot/palettes/Track 2.png"),
		preload("res://sprites/players/copy_robot/palettes/Poison Cloud.png"),
		preload("res://sprites/players/copy_robot/palettes/Fin Shredder.png"),
		preload("res://sprites/players/copy_robot/palettes/Origami Star.png"),
		preload("res://sprites/players/copy_robot/palettes/Wild Gale.png"),
		preload("res://sprites/players/copy_robot/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/copy_robot/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/players/copy_robot/palettes/Carry.png"),
		preload("res://sprites/players/copy_robot/palettes/Super Arrow.png"),
		preload("res://sprites/players/copy_robot/palettes/Mirror Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Screw Crusher.png"),
		preload("res://sprites/players/copy_robot/palettes/Ballade Cracker.png"),
		preload("res://sprites/players/copy_robot/palettes/Sakugarne.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX1.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png")
	]
	weapon_scenes = [
		preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/cr_fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn")
	]

# ================
# WEAPON FUNCTIONS
# ================
func weapon_buster(): # G: Copy Robot *can* charge his buster, but Maestro and Bass *can't*. Looks like we could easily do the same (replacing the Buster) with Bass's...?
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3):
			shot_type = 0
			attack_timer.start(0.3)
			GameState.onscreen_bullets += 1
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x + (sprite.scale.x * 18)
			projectile.position.y = position.y + 2
			projectile.velocity.x = sprite.scale.x * 350
			projectile.scale.x = sprite.scale.x
			Charge = 0
			return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3):
			if Charge < 32: # no Charge
				Charge = 0
				return
			if Charge >= 32 and Charge < 92: # medium charge
				shot_type = 0
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 1
				projectile = projectile_scenes[1].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 2
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				Charge = 0
				$Audio/Charge1.stop()
				return
			if Charge >= 92: # da big boi
				shot_type = 0
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 3
				projectile = projectile_scenes[2].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 2
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				Charge = 0
				return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
		if Charge < 110:
			Charge += 1
			if Charge == 32:
				$Audio/Charge1.play()
			if Charge == 105:
				$Audio/Charge2.play()
		else:
			Charge = 105
	else:
		Charge = 0
		return
		
func weapon_shark():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && is_on_floor() && GameState.weapon_energy[4] >= 5:
		GameState.weapon_energy[4] -= 3
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.51)
		projectile = weapon_scenes[4].instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x + sprite.scale.x * 15
		projectile.position.y = position.y - 3
		projectile.velocity.x = sprite.scale.x * 65
		projectile.scale.x = sprite.scale.x
		return
