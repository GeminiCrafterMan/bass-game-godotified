class_name StageSelect extends CanvasLayer

var fadeout : int = 120
var timer : int = 60

const _playerPortraits: Array[AtlasTexture] = [
	preload("res://sprites/Menus/Stage Select - Maestro - Atlas.tres"),
	preload("res://sprites/Menus/Stage Select - Bass - Atlas.tres"),
	preload("res://sprites/Menus/Stage Select - Copy Robot - Atlas.tres")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var player := %Player as StageSelectPanel
	player.portrait = _playerPortraits[GameState.character_selected]
	await Fade.fade_in().finished
	%Player.grab_focus()

func _process(delta):
	if timer == 0:
		$Darkness.hide()
		%Player.grab_focus()
		$Music.play()
		$Rows/RowBright.play()
		#$PortraitFlashes/PortraitFlash.play()
	timer -= 1
	
func panel_focused(index: int):
	var player := %Player as StageSelectPanel
	if not player: return
	var portrait := player.portrait as AtlasTexture
	if not portrait: return
	portrait.region.position.x = (floor(portrait.atlas.get_width()) / 9) * index
