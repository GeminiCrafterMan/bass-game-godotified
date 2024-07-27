extends Node2D

var stages = [
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

@onready var positions = [
	$"Robot Master Portraits/Blaze Man".position,
	$"Robot Master Portraits/Video Man".position,
	$"Robot Master Portraits/Smog Man".position,
	$"Robot Master Portraits/Shark Man".position,
	$"Player".position,
	$"Robot Master Portraits/Origami Man".position,
	$"Robot Master Portraits/Gale Woman".position,
	$"Robot Master Portraits/Guerrilla Man".position,
	$"Robot Master Portraits/Reaper Man".position
]

var stage_selected : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalVars.character_selected == 1: # Copy Robot was selected
		$Player.texture = load("res://sprites/Menus/Stage Select - Copy Robot.png")
	$Cursor.position = $Player.position
	stage_selected = 4
	await Fade.fade_in().finished

func _input(InputEvent):
	# cursor controls
	if stage_selected > 2 and Input.is_action_just_pressed("move_up"):
		stage_selected = stage_selected - 3
	if not (stage_selected == 0 or stage_selected == 3 or stage_selected == 6) and Input.is_action_just_pressed("move_left"):
		stage_selected = stage_selected - 1
	if not (stage_selected == 2 or stage_selected == 5 or stage_selected == 8) and Input.is_action_just_pressed("move_right"):
		stage_selected = stage_selected + 1
	if stage_selected < 6 and Input.is_action_just_pressed("move_down"):
		stage_selected = stage_selected + 3
	if stage_selected < 0:
		stage_selected = 0
	if stage_selected > 8:
		stage_selected = 8
	# enter selected stage upon pressing Start
	if Input.is_action_just_pressed("start") and stages[stage_selected] != null:
		await Fade.fade_out().finished
		Loading.load_scene(stages[stage_selected])
	if (Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right")):
		# update cursor
		$Cursor.position = positions[stage_selected]
		$Player.frame = stage_selected
		$SelectSound.play()