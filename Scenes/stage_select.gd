extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_test_stage_pressed():
	Loading.load_scene("res://Scenes/Stages/test_stage.tscn")

func _on_air_man_stage_pressed():
	Loading.load_scene("res://Scenes/Stages/airman_stage.tscn")

func _on_mengo_stage_pressed():
	Loading.load_scene("res://Scenes/Stages/mengo.tscn")
