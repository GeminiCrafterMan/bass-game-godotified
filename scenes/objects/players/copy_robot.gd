extends MaestroPlayer

class_name CopyRobotPlayer

func _init() -> void:
	weapon_palette = [
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Scorch Barrier.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Track 2.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Poison Cloud.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Fin Shredder.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Origami Star.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Wild Gale.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Rolling Bomb.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Boomerang Scythe.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/Players/Copy Robot/Palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/Players/Copy Robot/Palettes/Carry.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Super Arrow.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Mirror Buster.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Screw Crusher.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Ballade Cracker.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/Sakugarne.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/ChargeX1.png"),
		preload("res://sprites/Players/Copy Robot/Palettes/ChargeX2.png")
	]

func _ready() -> void:
	super._ready()

func weapon_buster(): # G: Copy Robot *can* charge his buster, but Maestro and Bass *can't*. Looks like we could easily do the same (replacing the Buster) with Bass's...?
	if (GameState.current_weapon == 0 and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
			shot_type = 0
			shoot_delay = 16
			projectile = projectile_scenes[0].instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.velocity.x = sprite.scale.x * 350
			projectile.scale.x = sprite.scale.x
			Charge = 0
			return
	if (GameState.current_weapon == 0 and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
			if Charge < 32: # no Charge
				Charge = 0
				return
			if Charge >= 32 and Charge < 92: # medium charge
				shot_type = 0
				shoot_delay = 16
				projectile = projectile_scenes[1].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				projectile.velocity.x = sprite.scale.x * 450
				projectile.scale.x = sprite.scale.x
				Charge = 0
				$Audio/Charge1.stop()
				return
			if Charge >= 92: # da big boi
				shot_type = 0
				shoot_delay = 16
				projectile = projectile_scenes[2].instantiate()
				get_parent().add_child(projectile)
				projectile.position.x = position.x
				projectile.position.y = position.y
				projectile.velocity.x = sprite.scale.x * 500
				projectile.scale.x = sprite.scale.x
				Charge = 0
				return
	if (GameState.current_weapon == 0 and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
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
