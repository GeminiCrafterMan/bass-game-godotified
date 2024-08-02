class_name TitleScreen extends CanvasLayer

func _ready() -> void:
	$CenterContainer/HBoxContainer/VBoxContainer/ItemList.select(GameState.character_selected, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		_on_startbutton_pressed()

func _on_startbutton_pressed():
	await Fade.fade_out().finished
	Loading.load_scene("res://scenes/menus/stage_select.tscn", true)

func _on_item_list_item_selected(index):
	GameState.character_selected = index
