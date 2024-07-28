extends Control

const stages = [
	# row 1
	"res://scenes/Stages/Robot Masters/blaze_man.tscn",		# Blaze Man
	"res://scenes/Stages/Robot Masters/video_man.tscn",		# Video Man
	"res://scenes/Stages/Robot Masters/smog_man.tscn",		# Smog Man
	# row 2
	"res://scenes/Stages/Robot Masters/shark_man.tscn",		# Shark Man
	"res://scenes/Stages/test_stage.tscn",					# Wily/Protoman/Bass Bashers...? Maybe those guys can hide in stages like the X-Hunters.
	"res://scenes/Stages/Robot Masters/origami_man.tscn",	# Origami Man
	# row 3
	"res://scenes/Stages/Robot Masters/gale_woman.tscn",	# Gale Woman
	"res://scenes/Stages/Robot Masters/guerrilla_man.tscn",	# Guerrilla Man
	"res://scenes/Stages/Robot Masters/reaper_man.tscn"		# Reaper Man
]

# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalVars.character_selected == 1: # Copy Robot was selected
		%Player.texture = load("res://sprites/Menus/Stage Select - Copy Robot.png")
	await Fade.fade_in().finished


func _on_panel_focus_entered():
	$SelectSound.play()
