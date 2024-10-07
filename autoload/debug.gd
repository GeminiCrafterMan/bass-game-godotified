extends Node
func _unhandled_input(event):
	if (event is InputEventKey) and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if GameState.player:
					get_node(GameState.player).reset(true) # Reset EVERYTHING about the player
					GameState.player = null
				get_tree().change_scene_to_file("res://scenes/menus/stage_select.tscn")
			KEY_F1: # Refill health
				GameState.refill_health()
			KEY_F2: # Refill ammo
				GameState.refill_ammo()
			# No F3, because that's our debug info button thanks to that plugin.
			#KEY_F4: # Kill current boss or bring him down to 1HP
			KEY_F5: # Reload the current level.
				if GameState.player:
					if get_node(GameState.player):
						get_node(GameState.player).reset(true) # Reset EVERYTHING about the player
				get_tree().reload_current_scene()
			KEY_F6: # Switch characters... despite the character scene only loading upon level load. /shrug
				match GameState.character_selected:
					# Comment case 0 out to allow Bass to be selected via F6.
					0: # Maestro, but remove this once Bass is at least selectable without crashing
						GameState.character_selected += 2 # Add 2, since Bass doesn't work yet and selecting him will crash.
					GameState.maxCharacterID: # Last available character, by default Copy Robot (and later Mega Man himself)
						GameState.character_selected = 0 # Reset to Maestro.
					_:
						GameState.character_selected += 1
			#KEY_F7:
			# No F8, because that's the button to exit the game.
			#KEY_F9:
			#KEY_F10:
			KEY_F11:
				match DisplayServer.window_get_mode():
					DisplayServer.WINDOW_MODE_WINDOWED:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
					DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					_:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#KEY_F12:
