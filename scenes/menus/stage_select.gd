class_name StageSelect extends CanvasLayer

var fadeout : int = 120
var timer : int = 60

const _playerPortraits: Array[AtlasTexture] = [
	preload("res://sprites/menus/Stage Select - Maestro - Atlas.tres"),
	preload("res://sprites/menus/Stage Select - Bass - Atlas.tres"),
	preload("res://sprites/menus/Stage Select - Copy Robot - Atlas.tres")
]

var char_palette: Array[Texture2D] = [
	preload("res://sprites/menus/mastageseltrans.png"),
	preload("res://sprites/menus/bastageseltrans.png"),
	preload("res://sprites/menus/crstageseltrans.png"),
	preload("res://sprites/menus/mmstageseltrans.png")
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
		
		$Background.material.set_shader_parameter("palette", char_palette[GameState.character_selected])
		$Rows.material.set_shader_parameter("palette", char_palette[GameState.character_selected])
			
		$"Rows/Row 2/RowPt1".material.set_shader_parameter("palette", char_palette[GameState.character_selected])
		$"Rows/Row 2/RowPt2".material.set_shader_parameter("palette", char_palette[GameState.character_selected])
		$"Rows/Row 2/RowPt3".material.set_shader_parameter("palette", char_palette[GameState.character_selected])
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man/VBoxContainer/Portrait/Border".material.set_shader_parameter("palette", char_palette[GameState.character_selected])
		
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Video Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Smog Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Shark Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Player/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Origami Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Gale Woman/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Guerilla Man/VBoxContainer/Portrait/PortraitFlash".play()
		$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Reaper Man/VBoxContainer/Portrait/PortraitFlash".play()
		
		
	timer -= 1
	
func panel_focused(index: int):
	var player := %Player as StageSelectPanel
	if not player: return
	var portrait := player.portrait as AtlasTexture
	if not portrait: return
	portrait.region.position.x = (floor(portrait.atlas.get_width()) / 9) * index
