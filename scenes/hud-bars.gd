extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Weapon bar
	if GameState.max_weapon_energy[GameState.current_weapon] == 0:
		$WeaponBar.visible = false
	else:
		$WeaponBar.visible = true
		$WeaponBar.frame = GameState.weapon_energy[GameState.current_weapon]
	if GameState.player != null:
		$HealthBar.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))
		$WeaponBar.material.set_shader_parameter("palette", get_node(GameState.player).get_node("AnimatedSprite2D").material.get_shader_parameter("palette"))

	# Health bar
	$HealthBar.frame = GameState.current_hp

	
