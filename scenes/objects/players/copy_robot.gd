extends MaestroPlayer

class_name CopyRobotPlayer

var sharkcharge : int

func _init() -> void:
	
	
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/carry.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/arrow.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/cr_fin_shredder.tscn")
	
	]

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
		preload("res://sprites/players/weapons/ScytheCharge1.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge0.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge1.png")
	]
	weapon_scenes = [
		preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn"),
		
	]

func _ready() -> void:
	super._ready()
	attack_timer = $FireDelay

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
				SoundManager.instance_poly("player", "charge1").release()
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
				SoundManager.play("player", "charge1")
			if Charge == 105:
				SoundManager.play("player", "charge2")
		else:
			Charge = 105
	else:
		Charge = 0
		return
		
func weapon_shark():
	if Input.is_action_just_released("shoot"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1 and GameState.weapon_energy[GameState.WEAPONS.SHARK] > 3:
			if sharkcharge < 25: #Uncharged. Single Fin Shredder

				anim.seek(0)
				shot_type = 4
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = weapon_scenes[4].instantiate()
				get_parent().add_child(projectile)
				
				
				
				if !is_on_floor():
					projectile.position.x = position.x + sprite.scale.x * 25
				else:
					projectile.position.x = position.x + sprite.scale.x * 15
				
				projectile.position.y = position.y - 3
				
				if !is_on_floor():
					projectile.velocity.x = sprite.scale.x * 45
				else:
					projectile.velocity.x = sprite.scale.x * 1
				projectile.scale.x = sprite.scale.x
				
				GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 3

			if sharkcharge > 25: #Charged. Double Fin Shredder!
				GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 4
				GameState.onscreen_sp_bullets += 1

				anim.seek(0)
				shot_type = 5
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = projectile_scenes[7].instantiate()
				get_parent().add_child(projectile)

				projectile.position.x = position.x + sprite.scale.x * 35
				projectile.position.y = position.y + 2
				
				projectile.velocity.x = sprite.scale.x * 0.1
				projectile.scale.x = sprite.scale.x

			sharkcharge = 0

	if !Input.is_action_pressed("shoot"):
		sharkcharge = 0

	if sharkcharge >= 25 && GameState.weapon_energy[GameState.WEAPONS.SHARK] < 6:
		sharkcharge = 2

	if Input.is_action_pressed("shoot") && GameState.weapon_energy[GameState.WEAPONS.SHARK] > 0:
		if sharkcharge < 78:
			sharkcharge += 1
			if sharkcharge == 26:
				SoundManager.play("player", "charge1")
		else:
			sharkcharge = 77
	else:
		Charge = 0
		SoundManager.instance_poly("player", "charge1").release()
		return
		
	
	
func scythe_charge_palette():
	if ScytheCharge > 0:
		Charge = 0
	if GameState.current_weapon != GameState.WEAPONS.REAPER:
		ScytheCharge = 0
	if ScytheCharge > 0 and ScytheCharge < 35: # no charge
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[19])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer += 1


	elif ScytheCharge >= 35 && ScytheCharge < 75: # just started charging
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[20])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer += 1


	elif ScytheCharge >= 75:
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[19])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[20])
			Flash_Timer += 1
			
	if sharkcharge > 0: #Fin Shredder!
		Charge = 0
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		sharkcharge = 0
	if sharkcharge > 0 and sharkcharge < 35: # no charge
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[21])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer += 1


	elif sharkcharge >= 35: #Double Fin Shredder!
		if Flash_Timer == 3:
			sprite.material.set_shader_parameter("palette",weapon_palette[22])
			Flash_Timer = 0
		else:
			sprite.material.set_shader_parameter("palette",weapon_palette[GameState.current_weapon])
			Flash_Timer += 1


func _on_teleported() -> void: # Reconnect this to play the sound.
# G: So, occasionally, this will (for some reason) fire a second time
# after some time and returning to the Idle state. Only happens once
# per life, with no apparent cause -- the player doesn't return to the
# Teleport state, so they shouldn't be emitting the "teleported" signal
# a second time... Do we REALLY have to have a bool for this too???
# Isn't that what signals are for!? Happens with Bass, too.
	SoundManager.play("copy_robot", "start") # why replace the teleport stuff for a single extra sound?
