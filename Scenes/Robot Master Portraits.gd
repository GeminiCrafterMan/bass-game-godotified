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
		$"Air Man".visible = false
	else:
		$"Gale Woman".visible = true
		$"Air Man".visible = true
	if GlobalVars.weapons_unlocked[7] == true:
		$"???? 2".visible = false
		$"Mengo".visible = false
	else:
		$"???? 2".visible = true
		$"Mengo".visible = true
	if GlobalVars.weapons_unlocked[8] == true:
		$"???? 3".visible = false
		$"Pump Man".visible = false
	else:
		$"???? 3".visible = true
		$"Pump Man".visible = true
