extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		await Fade.fade_out().finished
		Loading.load_scene("res://Scenes/stage_select.tscn")

func _on_option_button_item_selected(index):
	if index == 0:
		GlobalVars.character_selected = false
	if index == 1:
		GlobalVars.character_selected = true