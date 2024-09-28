@tool
class_name StageSelectPanel extends MarginContainer

var selected: bool
var hovered: bool

var _stageName: String = "LOREM"
@export var stageName: String :
	get:
		return _stageName
	set(value):
		_stageName = value
		if not is_inside_tree():
			await ready
		$VBoxContainer/Text/VBoxContainer/Name.text = _stageName
		
var _stageTitle: String = "IPSUM"
@export var stageTitle: String :
	get:
		return _stageTitle
	set(value):
		_stageTitle = value
		if not is_inside_tree():
			await ready
		$VBoxContainer/Text/VBoxContainer/Title.text = _stageTitle
var _portrait: Texture2D
@export var portrait: Texture2D :
	get:
		return _portrait
	set(value):
		_portrait = value
		if not is_inside_tree():
			await ready
		$VBoxContainer/Portrait/Border/Image.texture = _portrait

@export var scene: PackedScene

var _beaten: bool
@export var beaten : bool :
	get:
		return _beaten
	set(value):
		_beaten = value
		if not is_inside_tree():
			await ready
		$VBoxContainer/Portrait/Border/Image.visible = !value
		

var _destroyed: bool
@export var destroyed : bool :
	get:
		return _destroyed
	set(value):
		_destroyed = value
		if not is_inside_tree():
			await ready
		$VBoxContainer/Portrait/Border.theme_type_variation = "RobotMasterPanelDestroyed" if value else "RobotMasterPanel"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not Engine.is_editor_hint():
		if selected or hovered:
			$VBoxContainer/Portrait/Lights.visible = true
		else:
			$VBoxContainer/Portrait/Lights.visible = false

func _gui_input(event):
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEvent and event.is_action_pressed("ui_accept")):
		get_tree().change_scene_to_file(scene.resource_path)
		#die -lynn
		#await Fade.fade_out().finished
		#Loading.load_scene(scene.resource_path, true)
	
func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			hovered = true
			$SelectSound.play()
		NOTIFICATION_MOUSE_EXIT:
			hovered = false
		NOTIFICATION_FOCUS_ENTER:
			selected = true
			$SelectSound.play()
		NOTIFICATION_FOCUS_EXIT:
			selected = false
