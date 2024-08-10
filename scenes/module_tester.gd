extends CanvasLayer

func _process(delta: float) -> void:
	transform = get_parent().transform
	offset -= Vector2(384/2, 216/2) 

func _on_check_button_1_toggled(toggled_on):
	GameState.modules_enabled[1] = toggled_on

func _on_check_button_2_toggled(toggled_on):
	GameState.modules_enabled[2] = toggled_on

func _on_check_button_3_toggled(toggled_on):
	GameState.modules_enabled[3] = toggled_on

func _on_check_button_4_toggled(toggled_on):
	GameState.modules_enabled[4] = toggled_on

func _on_check_button_5_toggled(toggled_on):
	GameState.modules_enabled[5] = toggled_on

func _on_check_button_6_toggled(toggled_on):
	GameState.modules_enabled[6] = toggled_on

func _on_check_button_7_toggled(toggled_on):
	GameState.modules_enabled[7] = toggled_on

func _on_check_button_8_toggled(toggled_on):
	GameState.modules_enabled[8] = toggled_on

func _on_check_button_9_toggled(toggled_on):
	GameState.modules_enabled[9] = toggled_on

func _on_check_button_10_toggled(toggled_on):
	GameState.weapons_unlocked[1] = toggled_on

func _on_check_button_11_toggled(toggled_on):
	GameState.weapons_unlocked[2] = toggled_on

func _on_check_button_12_toggled(toggled_on):
	GameState.weapons_unlocked[3] = toggled_on

func _on_check_button_13_toggled(toggled_on):
	GameState.weapons_unlocked[4] = toggled_on

func _on_check_button_14_toggled(toggled_on):
	GameState.weapons_unlocked[5] = toggled_on

func _on_check_button_15_toggled(toggled_on):
	GameState.weapons_unlocked[6] = toggled_on

func _on_check_button_16_toggled(toggled_on):
	GameState.weapons_unlocked[7] = toggled_on

func _on_check_button_17_toggled(toggled_on):
	GameState.weapons_unlocked[8] = toggled_on

func _on_check_button_18_toggled(toggled_on):
	GameState.weapons_unlocked[9] = toggled_on

func _on_check_button_19_toggled(toggled_on):
	GameState.weapons_unlocked[10] = toggled_on

func _on_button_toggled(toggled_on):
	if toggled_on == true:
		$Modules.hide()
		$Weapons.hide()
	else:
		$Modules.show()
		$Weapons.show()


func _on_check_button_20_toggled(toggled_on):
	GameState.weapons_unlocked[11] = toggled_on
	
func _on_check_button_21_toggled(toggled_on):
	GameState.weapons_unlocked[12] = toggled_on





func _on_check_button_23_toggled(toggled_on):
	GameState.weapons_unlocked[13] = toggled_on


func _on_check_button_24_toggled(toggled_on):
	GameState.weapons_unlocked[14] = toggled_on


func _on_check_button_25_toggled(toggled_on):
	GameState.weapons_unlocked[15] = toggled_on


func _on_check_button_26_toggled(toggled_on):
	GameState.weapons_unlocked[16] = toggled_on
