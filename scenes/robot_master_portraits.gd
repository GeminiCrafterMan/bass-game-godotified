extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GlobalVars.weapons_unlocked[1] == true:
		$"Blaze Man".visible = false
	else:
		$"Blaze Man".visible = true
	if GlobalVars.weapons_unlocked[2] == true:
		$"Video Man".visible = false
	else:
		$"Video Man".visible = true
	if GlobalVars.weapons_unlocked[3] == true:
		$"Smog Man".visible = false
	else:
		$"Smog Man".visible = true
	if GlobalVars.weapons_unlocked[4] == true:
		$"Shark Man".visible = false
	else:
		$"Shark Man".visible = true
	if GlobalVars.weapons_unlocked[5] == true:
		$"Origami Man".visible = false
	else:
		$"Origami Man".visible = true
	if GlobalVars.weapons_unlocked[6] == true:
		$"Gale Woman".visible = false
	else:
		$"Gale Woman".visible = true
	if GlobalVars.weapons_unlocked[7] == true:
		$"Guerrilla Man".visible = false
	else:
		$"Guerrilla Man".visible = true
	if GlobalVars.weapons_unlocked[8] == true:
		$"Reaper Man".visible = false
	else:
		$"Reaper Man".visible = true