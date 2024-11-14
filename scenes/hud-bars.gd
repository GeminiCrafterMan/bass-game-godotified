extends Node

@onready var refill_timer = $RefillTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Weapon bar
	if GameState.max_weapon_energy[GameState.current_weapon] == 0:
		$WeaponBar.visible = false
	else:
		$WeaponBar.visible = true
		if GameState.weapon_energy[GameState.current_weapon] < 0:
			GameState.weapon_energy[GameState.current_weapon] = 0
		$WeaponBar.frame = GameState.weapon_energy[GameState.current_weapon]
	if GameState.player != null:
		$HealthBar.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
		$WeaponBar.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
		
	# Health bar
	$HealthBar.frame = GameState.current_hp
	
func _physics_process(delta: float):
	process_refills()

func process_refills():
	if (GameState.player != null): # Null check!
		if (GameState.ammoamt):
			if refill_timer.is_stopped():
				if GameState.weapon_energy[GameState.current_weapon] < GameState.max_weapon_energy[GameState.current_weapon]:
					refill_timer.start()
					GameState.weapon_energy[GameState.current_weapon] += 1
					GameState.ammoamt -= 1
					SoundManager.play("generic", "bar_fill")
				else:
					GameState.ammoamt = 0
			
		if (GameState.healamt):
			if refill_timer.is_stopped():
				if GameState.current_hp < GameState.max_hp:
					refill_timer.start()
					GameState.current_hp += 1
					GameState.healamt -= 1
					SoundManager.play("generic", "bar_fill")
				else:
					GameState.healamt = 0
