extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		await Fade.fade_out().finished
		Loading.load_scene("res://Scenes/stage_select.tscn")

func _on_startbutton_pressed():
	await Fade.fade_out().finished
	Loading.load_scene("res://Scenes/Stages/test_stage.tscn")

func _on_item_list_item_selected(index):
	GlobalVars.character_selected = index
