extends MaestroPlayer

# Enums
enum WEAPONS {BUSTER, GALAXY, TOP, GEMINI, GRENADE, YAMATO, MAGMA, PHARAOH, CHILL, ROSE, WIRE, BALLOON, MAGNET, TERRA, MERCURY, MARS, PLUTO}

func _init() -> void:
	weapon_palette = [
		preload("res://sprites/players/rachel/palettes/Rachel Buster.png"),
		preload("res://sprites/players/rachel/palettes/Black Hole Bomb.png"),
		preload("res://sprites/players/rachel/palettes/Top Spin.png"),
		preload("res://sprites/players/rachel/palettes/Gemini Laser.png"),
		preload("res://sprites/players/rachel/palettes/Flash Bomb.png"),
		preload("res://sprites/players/rachel/palettes/Yamato Spear.png"),
		preload("res://sprites/players/rachel/palettes/Magma Bazooka.png"),
		preload("res://sprites/players/rachel/palettes/Pharaoh Wave.png"),
		preload("res://sprites/players/rachel/palettes/Chill Spike.png"),
		preload("res://sprites/players/rachel/palettes/Piko Hammer.png"),
		preload("res://sprites/players/rachel/palettes/Adaptors.png"),
		preload("res://sprites/players/rachel/palettes/Adaptors.png"),
		preload("res://sprites/players/rachel/palettes/Magnet Beam.png"),
		preload("res://sprites/players/rachel/palettes/Spark Chaser.png"),
		preload("res://sprites/players/rachel/palettes/Grab Buster.png"),
		preload("res://sprites/players/rachel/palettes/Photon Missile.png"),
		preload("res://sprites/players/rachel/palettes/Break Dash.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX1.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png")
	]

	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/rachel/weapons/balloon_adaptor.tscn")
	]

	weapon_scenes = [
		preload("res://scenes/objects/players/rachel/weapons/pharaoh_wave.tscn")
	]

func handle_weapons():
	if !attack_timer.is_stopped():
		if shot_type > 0:
			no_grounded_movement = true
	else:
		no_grounded_movement = false

	match GameState.current_weapon:
		WEAPONS.GALAXY:
			weapon_galaxy()
		WEAPONS.TOP:
			weapon_top()
		WEAPONS.GEMINI:
			weapon_gemini()
		WEAPONS.GRENADE:
			weapon_grenade()
		WEAPONS.YAMATO:
			weapon_yamato()
		WEAPONS.MAGMA:
			weapon_magma()
		WEAPONS.PHARAOH:
			weapon_pharaoh()
		WEAPONS.CHILL:
			weapon_chill()
		WEAPONS.ROSE:
			weapon_rose()
		WEAPONS.WIRE:
			weapon_wire()
		WEAPONS.BALLOON:
			weapon_balloon()
		WEAPONS.MAGNET:
			weapon_magnet()
		WEAPONS.TERRA:
			weapon_terra()
		WEAPONS.MERCURY:
			weapon_mercury()
		WEAPONS.MARS:
			weapon_mars()
		WEAPONS.PLUTO:
			weapon_pluto()
		_:
			return

# ================
# WEAPON FUNCTIONS
# ================

# See, there's a problem... We can't do anything involving weapon damage until we rework the weapon damage system!

## Black Hole Bomb
## Uses 4 WE, and deals 1 damage per hit.
## Fires a black hole that, when the button is pressed again, expands and starts to suck in projectiles and enemies. Multi-hits very frequently.
func weapon_galaxy():
	return

## Top Spin
## Uses 1 WE per hit, and deals 3 damage per hit.
## Makes its user spin rapidly, gives them full immunity to all enemies and attacks during its use, and allows them to bounce off enemies from the top.
func weapon_top():
	return

## Gemini Laser
## Uses 2 WE, and each segment deals 1 damage.
## Fires a 3-segment laser that bounces off of surfaces for a while, until eventually going offscreen on its own.
func weapon_gemini():
	return

## Flash Bomb
## Uses 1.12 WE, and deals 0.5 damage each time it hits, up to a total of 15 damage. 0.5 damage/0.05 seconds.
## Fires a bomb that explodes on contact with anything, dealing rapidly-hitting radius damage and lingering for 1.5 seconds.
func weapon_grenade():
	return

## Yamato Spear
## Uses 1 WE, and deals ? damage.
## Fires a piercing projectile that either moves up or down depending on which direction it went last.
func weapon_yamato():
	return

## Magma Bazooka
## Uncharged: Fires three small shots in a spread pattern. Uses 0.5 WE, and deals 1 damage.
## Charged: Fires three large shots in a spread pattern. Uses 3 WE, and deals 3 damage.
func weapon_magma():
	return

## Pharaoh Wave
## Uses 1.75 WE, and deals ? damage.
## Fires two waves, one on each side of the user, that pierce armor and shields.
func weapon_pharaoh():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && GameState.weapon_energy[WEAPONS.PHARAOH] >= 1.75:
		if GameState.onscreen_sp_bullets == 0:
			GameState.weapon_energy[WEAPONS.PHARAOH] -= 1.75
			GameState.onscreen_sp_bullets += 2
			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)

			projectile.position.x = position.x + 5
			projectile.position.y = position.y
			projectile.velocity.x = 200
			projectile.scale.x = 1

			projectile = weapon_scenes[0].instantiate()
			get_parent().add_child(projectile)

			projectile.position.x = position.x - 5
			projectile.position.y = position.y
			projectile.velocity.x = -200
			projectile.scale.x = -1
			return

## Chill Spike
## Uses 1 WE. Glob deals 1 damage and freezes the enemy it hit, and spikes deal 2 damage.
## Fires a glob of an instantly-freezing material in an arc. Creates ice spikes when it hits a wall or floor, which break on contact or after a little bit of inactivity.
func weapon_chill():
	return

## Piko Hammer
## Uses ? WE, and deals ? damage.
## A melee weapon that bounces you off of enemies when hit from above.
func weapon_rose():
	return

## Wire Adaptor
## Uses 2 WE, and can deal 1 damage if an enemy is hit by the hook on its way up.
## Fires a grappling hook at the ceiling that pulls you to itself (with 5 pixels between the top of the hook sprite and yourself).
func weapon_wire():
	return

## Balloon Adaptor
## Uses 2 WE, and deals no damage.
## Creates a balloon platform in front of you that slowly rises up and squishes when you stand on it.
func weapon_balloon():
	if Input.is_action_just_pressed("shoot") && GameState.weapon_energy[WEAPONS.BALLOON] >= 2 && GameState.onscreen_sp_bullets < 3:
		anim.seek(0)
		GameState.weapon_energy[WEAPONS.BALLOON] -= 2
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[1].instantiate()
		get_parent().add_child(projectile)

		projectile.position.y = position.y
		projectile.position.x = position.x + sprite.scale.x * 30

## Magnet Beam
## Uses 2 WE, no matter how long the platform is, and deals no damage.
## A tool that creates a temporary platform of varying length depending on how long you hold the button.
func weapon_magnet():
	return

## Spark Chaser
## Deals 1 damage per hit, uses 2 WE.
## Multi-hitting weapon that stops to dart back and forth between enemies.
func weapon_terra():
	return

## Grab Buster
## Uses 1 WE, and deals 1 damage.
## Fires a shot that heals you for 2HP if it hits.
func weapon_mercury():
	return

# G: okay, so the Megaman wiki was being really stupid about this one and had conflicting information, so I made up my own numbers
## Photon Missile
## Uses 2 WE, and deals 3 damage in a radius.
## Fires a missile with a delayed launch that can be repositioned if the button is held.
func weapon_mars():
	return

## Break Dash
## Uncharged: Fires a standard Buster shot. Uses 0 WE, and deals 1 damage...?
## Charged: Dashes forward for a while and deals contact damage, while invincible to enemy attacks. Uses 2 WE, and deals 4 damage.
func weapon_pluto():
	return
